"""FastAPI backend replacing the GUIDE callbacks of rf_impairments.m."""

from __future__ import annotations

from pathlib import Path
from typing import Literal

import numpy as np
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

from rf_impairments import dsp
from rf_impairments.simulation import N_FFT, N_SD, SimParams, simulate

STATIC = Path(__file__).parent / "static"

# Popup entries of the original GUI (popupmenu_sco / popupmenu_cfo)
PPM_CHOICES = [0.0, 0.1, 1.0, 10, 15, 50, 100, -0.1, -1.0, -10, -15, -50, -100]
MODULATIONS = {"BPSK": 2, "QPSK": 4, "16-QAM": 16, "64-QAM": 64}

app = FastAPI(title="LTE - RF Impairments")


class SimRequest(BaseModel):
    transmission: Literal["ofdm", "single"] = "ofdm"
    modulation: Literal["BPSK", "QPSK", "16-QAM", "64-QAM"] = "BPSK"
    sco_ppm: float = 0.0
    cfo_ppm: float = 0.0
    t_offset: float = Field(0.0, ge=-1, le=1, description="samples")
    phase_deg: float = Field(0.0, ge=0, le=360)
    pn_level: float | None = -120.0
    pn_fo: float | None = 100.0
    amp_imbal: float | None = 0.0
    phs_imbal: float | None = 0.0
    dc_i: float | None = 0.0
    dc_q: float | None = 0.0
    snr_db: float | None = None  # None = noiseless (MATLAB uses 1000 dB)
    random_data: bool = False


class SimResponse(BaseModel):
    rx: list[list[float]]  # [[I, Q], ...]
    tx: list[list[float]]
    ideal: list[list[float]]
    t_offset: float  # carried over into the slider for the next run
    phase_deg: float
    evm_percent: float
    evm_db: float
    applied: dict  # sanitised inputs, written back to the form like the GUI does


def _pairs(z: np.ndarray) -> list[list[float]]:
    return np.column_stack([z.real, z.imag]).round(6).tolist()


@app.get("/api/config")
def config() -> dict:
    return {
        "ppm_choices": PPM_CHOICES,
        "modulations": list(MODULATIONS),
        "transmissions": {
            "ofdm": f"OFDM ({N_SD} of {N_FFT} carriers)",
            "single": f"Single-Carrier ({N_SD} symbols)",
        },
    }


@app.post("/api/simulate", response_model=SimResponse)
def run(req: SimRequest) -> SimResponse:
    # same input sanitising as pushbutton1_Callback
    pn_level = min(-120.0 if req.pn_level is None else req.pn_level, 0.0)
    pn_fo = max(0.0 if req.pn_fo is None else req.pn_fo, 0.0)
    amp_imbal = req.amp_imbal or 0.0
    phs_imbal = req.phs_imbal or 0.0
    dc_i = req.dc_i or 0.0
    dc_q = req.dc_q or 0.0
    M = MODULATIONS[req.modulation]

    res = simulate(
        SimParams(
            M=M,
            sco_ppm=req.sco_ppm,
            t_offset=req.t_offset,
            cfo_ppm=req.cfo_ppm,
            phase_offset=req.phase_deg / 180 * np.pi,
            ofdm=req.transmission == "ofdm",
            pn_level=pn_level,
            pn_fo=pn_fo,
            amp_imbal=amp_imbal,
            phs_imbal=phs_imbal,
            dc_i=dc_i,
            dc_q=dc_q,
            snr_db=1000.0 if req.snr_db is None else req.snr_db,
            random_data=req.random_data,
        )
    )

    phase = float(np.mod(res.phase_offset, 2 * np.pi))
    t_offset = float(np.clip(res.last_delay, -1, 1))
    err = np.mean(np.abs(res.rx - res.tx) ** 2) / np.mean(np.abs(res.tx) ** 2)
    evm = float(np.sqrt(err))

    return SimResponse(
        rx=_pairs(res.rx),
        tx=_pairs(res.tx),
        ideal=_pairs(dsp.constellation(M)),
        t_offset=t_offset,
        phase_deg=float(phase / np.pi * 180) % 360,
        evm_percent=100 * evm,
        evm_db=float(20 * np.log10(evm)) if evm > 0 else -300.0,
        applied={"pn_level": pn_level, "pn_fo": pn_fo, "amp_imbal": amp_imbal,
                 "phs_imbal": phs_imbal, "dc_i": dc_i, "dc_q": dc_q},
    )


@app.get("/")
def index() -> FileResponse:
    return FileResponse(STATIC / "index.html")


app.mount("/static", StaticFiles(directory=STATIC), name="static")


def main() -> None:
    import uvicorn

    uvicorn.run("rf_impairments.app:app", host="127.0.0.1", port=8000)


if __name__ == "__main__":
    main()
