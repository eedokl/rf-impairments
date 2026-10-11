import numpy as np
import pytest
from fastapi.testclient import TestClient
from scipy.signal import lfilter

from rf_impairments import dsp
from rf_impairments.app import app
from rf_impairments.simulation import N_FFT, N_GI, SC_HZ, CF_HZ, SimParams, simulate


@pytest.mark.parametrize("M", [2, 4, 16, 64])
@pytest.mark.parametrize("ofdm", [True, False])
def test_no_impairments_is_transparent(M, ofdm):
    res = simulate(SimParams(M=M, ofdm=ofdm, random_data=True, pn_level=-300, seed=1))
    assert np.max(np.abs(res.rx - res.tx)) < 1e-3


def test_constellation_power_is_unity():
    for M in (2, 4, 16, 64):
        pts = dsp.constellation(M)
        assert len(np.unique(pts.round(9))) == M
        assert np.mean(np.abs(pts) ** 2) == pytest.approx(1.0)


def test_cfo_single_carrier_rotation_and_phase_carry():
    p = SimParams(M=2, ofdm=False, cfo_ppm=10, phase_offset=0.3, pn_level=-300)
    res = simulate(p)
    dphi = 2 * np.pi / SC_HZ * (10e-6 * CF_HZ)
    n = np.arange(len(res.tx))
    expected = res.tx * np.exp(1j * (dphi * n + 0.3))
    assert np.max(np.abs(res.rx - expected)) < 1e-3
    assert res.phase_offset == pytest.approx(np.fmod(dphi * len(n) + 0.3, 2 * np.pi))


def test_sco_drift_carried_over():
    res = simulate(SimParams(sco_ppm=100, t_offset=0.2))
    assert res.last_delay == pytest.approx(0.2 + 100e-6 * (N_FFT + N_GI - 1))


def test_time_varying_filter_matches_matlab_loop():
    rng = np.random.default_rng(0)
    n, L = 50, 32
    x = rng.standard_normal(n) + 1j * rng.standard_normal(n)
    coefs, _ = dsp.gen_gls_coef(False, L, 0.87, 1e5, CF_HZ, SC_HZ, n, 0.3)

    # literal port of the MATLAB per-sample filter() loop with carried state
    state = np.zeros(L - 1, dtype=complex)
    y = np.zeros(n + L - 1, dtype=complex)
    for i in range(n):
        out, state = lfilter(coefs[i], [1.0], [x[i]], zi=state)
        y[i] = out[0]
    for i in range(n, n + L - 1):
        out, state = lfilter(coefs[-1], [1.0], [0.0], zi=state)
        y[i] = out[0]
    ref = y[L // 2 : len(y) - (L // 2 - 1)]

    assert np.allclose(dsp.add_sco_interpolate(x, coefs, True), ref)


def test_api_roundtrip():
    client = TestClient(app)
    r = client.post("/api/simulate", json={"modulation": "16-QAM", "pn_level": 5, "pn_fo": -3,
                                          "cfo_ppm": 1, "phase_deg": 350})
    assert r.status_code == 200
    body = r.json()
    assert len(body["rx"]) == 72 and len(body["ideal"]) == 16
    assert body["applied"]["pn_level"] == 0 and body["applied"]["pn_fo"] == 0
    assert 0 <= body["phase_deg"] < 360
    assert client.get("/").status_code == 200
