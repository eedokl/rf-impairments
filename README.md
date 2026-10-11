# LTE RF Impairments — FastAPI port

Python/FastAPI + vanilla HTML/JS port of the MATLAB GUIDE app `rf_impairments.m`
(see the parent folder). It shows the received constellation of one packet after
a dirty-RF chain:

datamod → OFDM (72 of 128 carriers, GI 9) → IQ imbalance → DC offset → CFO →
sampling clock offset (32-tap GLS fractional-delay filter) → phase noise → AWGN → FFT

## Run

```bash
uv sync
uv run rf-impairments               # http://127.0.0.1:8000
# also works: uv run python -m rf_impairments, python rf_impairments/app.py (venv active)
uv run pytest
```

## MATLAB → Python map

| MATLAB                                   | Python                                   |
|------------------------------------------|------------------------------------------|
| `rf_impairments.m` / `.fig` callbacks    | `rf_impairments/app.py`, `static/*`      |
| `samp_clock_offset_simulation_function.m`| `rf_impairments/simulation.py`           |
| `datamod`, `ofdmmod`, `ofdmdmod`, `gi_rem`, `add_iq_imbalance_ld`, `add_dc_offset`, `add_cfo`, `gls_coef`, `gen_gls_coef`, `add_sco_interpolate`, `add_phase_noise` | `rf_impairments/dsp.py` |

As in the GUI, each **Run** simulates one packet and writes the end-of-packet
time and phase offsets back into the sliders, so repeated runs show the drift.

## Differences from the MATLAB GUI

- Carried-over phase keeps full precision. MATLAB rounds it to whole degrees,
  which freezes small CFOs (0.1 ppm ≈ 0.4°/packet → always rounds back to 0°).
- The GUI's DC offset labels had no input fields; they are wired up here
  (the simulation function already supported `DC_I`/`DC_Q`).
- Extras: SNR slider (MATLAB hard-codes 1000 dB = ∞), optional random payload
  (MATLAB sends all-zero bits), ideal-point overlay, EVM, persistence, animation,
  dark mode.
- The transmission label shows the real sizes (72 of 128), not the stale
  "1201 of 2048" text from the `.fig`.
