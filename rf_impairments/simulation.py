"""Port of samp_clock_offset_simulation_function.m (one packet, as used by the GUI).

Chain: datamod -> [OFDM mod] -> IQ imbalance -> DC offset -> CFO -> SCO
(fractional-delay interpolation) -> phase noise -> AWGN -> [GI removal, FFT].
WP/SCO compensation are switched off in the MATLAB code and therefore omitted.
"""

from __future__ import annotations

from dataclasses import dataclass

import numpy as np

from rf_impairments import dsp

SC_HZ = 30.72e6  # sampling clock
CF_HZ = 2.5e9  # carrier frequency
N_FFT = 128
N_GI = 9
N_SD = 72  # used subcarriers / single-carrier symbols per packet
L_FD = 32  # fractional delay filter length
WP_FD = 0.87  # passband edge of the FD filter


@dataclass
class SimParams:
    M: int = 4
    sco_ppm: float = 0.0
    t_offset: float = 0.0  # initial sampling time offset [samples]
    cfo_ppm: float = 0.0
    phase_offset: float = 0.0  # initial carrier phase [rad]
    ofdm: bool = True
    pn_level: float = -120.0  # dBc/Hz
    pn_fo: float = 100.0  # Hz
    amp_imbal: float = 0.0  # linear
    phs_imbal: float = 0.0  # deg
    dc_i: float = 0.0
    dc_q: float = 0.0
    snr_db: float = 1000.0  # MATLAB hard-codes 1000 dB (i.e. noiseless)
    random_data: bool = False  # MATLAB transmits all-zero bits (tx_bits = 0*...)
    seed: int | None = None


@dataclass
class SimResult:
    rx: np.ndarray  # received constellation (complex)
    tx: np.ndarray  # transmitted constellation (complex)
    last_delay: float  # sampling offset at the end of the packet [samples]
    phase_offset: float  # carrier phase at the end of the packet [rad]
    n_tx_packet: int


def simulate(p: SimParams) -> SimResult:
    rng = np.random.default_rng(p.seed)
    n_tx_packet = N_GI + N_FFT if p.ofdm else N_SD
    cfo_hz = p.cfo_ppm / 1e6 * CF_HZ

    # Loading section: fractional delay coefficients from the SCO in ppm
    sco_hz = p.sco_ppm / 1e6 * CF_HZ
    coefs, last_delay = dsp.gen_gls_coef(
        False, L_FD, WP_FD, sco_hz, CF_HZ, SC_HZ, n_tx_packet, p.t_offset
    )

    # ---- transmitter
    n_bits = N_SD * int(np.log2(p.M))
    tx_bits = rng.integers(0, 2, n_bits) if p.random_data else np.zeros(n_bits, dtype=int)
    tx_data = dsp.datamod(tx_bits, p.M)
    tx_packet = dsp.ofdmmod(tx_data, N_FFT, N_GI, N_SD)[0] if p.ofdm else tx_data

    # ---- impairments
    x = dsp.add_iq_imbalance_ld(tx_packet, True, p.amp_imbal, p.phs_imbal)
    x = dsp.add_dc_offset(x, True, p.dc_i, p.dc_q)
    x, phase_offset = dsp.add_cfo(x, True, n_tx_packet, cfo_hz, SC_HZ, p.phase_offset)
    x = dsp.add_sco_interpolate(x, coefs, True)
    x = dsp.add_phase_noise(x, True, p.pn_level, p.pn_fo, rng)

    # ---- AWGN
    snr = 10 ** (p.snr_db / 10)
    amp = 1 / np.sqrt(2 * snr)
    x = x + amp * (rng.standard_normal(n_tx_packet) + 1j * rng.standard_normal(n_tx_packet))

    # ---- inner receiver
    if p.ofdm:
        x = dsp.ofdmdmod(dsp.gi_rem(x, 0, N_FFT, N_GI), N_FFT, N_SD)

    return SimResult(rx=x, tx=tx_data, last_delay=last_delay, phase_offset=phase_offset,
                     n_tx_packet=n_tx_packet)
