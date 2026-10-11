"""DSP building blocks, ported 1:1 from the MATLAB functions of rf_impairments.

Each function names the MATLAB file it was translated from. Signals are 1-D
complex numpy arrays (MATLAB row vectors).
"""

from __future__ import annotations

import warnings

import numpy as np
from scipy.linalg import solve, toeplitz
from scipy.signal import lfilter

K_MOD = {2: 1.0, 4: 1 / np.sqrt(2), 16: 1 / np.sqrt(10), 64: 1 / np.sqrt(42)}


# --------------------------------------------------------------------------
# datamod.m — 802.11a mapping (Heiko Schmidt, eq. 5.1.3/5/9/12)
# --------------------------------------------------------------------------
def datamod(bits: np.ndarray, M: int) -> np.ndarray:
    k = int(np.log2(M))
    # MATLAB reshape(block, log2(M), []) is column-major: row r = bit r of each symbol
    b = np.asarray(bits, dtype=float).reshape(-1, k).T
    if M == 2:
        i, q = 2 * b[0] - 1, np.zeros(b.shape[1])
    elif M == 4:
        i, q = 2 * b[0] - 1, 2 * b[1] - 1
    elif M == 16:
        i = (2 * b[0] - 1) * (3 - 2 * b[1])
        q = (2 * b[2] - 1) * (3 - 2 * b[3])
    elif M == 64:
        i = (2 * b[0] - 1) * (4 - (2 * b[1] - 1) * (3 - 2 * b[2]))
        q = (2 * b[3] - 1) * (4 - (2 * b[4] - 1) * (3 - 2 * b[5]))
    else:
        raise ValueError(f"unsupported modulation order M={M}")
    return K_MOD[M] * (i + 1j * q)


def constellation(M: int) -> np.ndarray:
    """All ideal constellation points of datamod for order M."""
    k = int(np.log2(M))
    bits = ((np.arange(M)[:, None] >> np.arange(k)) & 1).ravel()
    return datamod(bits, M)


# --------------------------------------------------------------------------
# ofdmmod.m / ofdmdmod.m / gi_rem.m  (single OFDM symbol per packet)
# --------------------------------------------------------------------------
def _first_carrier(n_fft: int, n_sd: int) -> int:
    # MATLAB: ll = ceil((N_FFT-N_SD+1)/2); carriers at ll+[1:N_SD] (1-based)
    return int(np.ceil((n_fft - n_sd + 1) / 2))


def ofdmmod(data: np.ndarray, n_fft: int, n_gi: int, n_sd: int) -> tuple[np.ndarray, int]:
    n_sym = len(data) // n_sd
    blocks = np.zeros((n_sym, n_fft), dtype=complex)
    ll = _first_carrier(n_fft, n_sd)
    blocks[:, ll : ll + n_sd] = data.reshape(n_sym, n_sd)
    td = np.fft.ifft(np.fft.fftshift(blocks, axes=1), n_fft, axis=1) * np.sqrt(n_fft)
    if n_gi > 0:
        td = np.concatenate([td[:, n_fft - n_gi :], td], axis=1)
    return td.ravel(), n_sym


def gi_rem(block: np.ndarray, wplacement: int, n_fft: int, n_gi: int) -> np.ndarray:
    sub = block.reshape(-1, n_fft + n_gi)
    return sub[:, n_gi + wplacement : n_gi + wplacement + n_fft].ravel()


def ofdmdmod(block: np.ndarray, n_fft: int, n_sd: int) -> np.ndarray:
    sub = block.reshape(-1, n_fft)
    fd = np.fft.fftshift(np.fft.fft(sub, n_fft, axis=1), axes=1) / np.sqrt(n_fft)
    ll = _first_carrier(n_fft, n_sd)
    return fd[:, ll : ll + n_sd].ravel()


# --------------------------------------------------------------------------
# add_iq_imbalance_ld.m — "A UE perspective on ... LTE"
# --------------------------------------------------------------------------
def add_iq_imbalance_ld(x: np.ndarray, on: bool, alpha: float, theta_deg: float) -> np.ndarray:
    if not on:
        return x
    theta = theta_deg / 180 * np.pi
    a = np.cos(theta) + 1j * alpha * np.sin(theta)
    b = alpha * np.cos(theta) - 1j * np.sin(theta)
    return a * x + b * np.conj(x)


# --------------------------------------------------------------------------
# add_dc_offset.m
# --------------------------------------------------------------------------
def add_dc_offset(x: np.ndarray, on: bool, dc_i: float = 0.0, dc_q: float = 0.0) -> np.ndarray:
    return x + (dc_i + 1j * dc_q) if on else x


# --------------------------------------------------------------------------
# add_cfo.m — returns (rotated block, phase at start of next packet)
# --------------------------------------------------------------------------
def add_cfo(
    x: np.ndarray, on: bool, n: int, fo_hz: float, samp_rate: float, start_phase: float = 0.0
) -> tuple[np.ndarray, float]:
    if not on:
        return x, 0.0
    dphi = 2 * np.pi / samp_rate * fo_hz
    out = x * np.exp(1j * (dphi * np.arange(n) + start_phase))
    # MATLAB rem() keeps the sign of the dividend, like math.fmod
    last_phase = float(np.fmod(dphi * n + start_phase, 2 * np.pi))
    return out, last_phase


# --------------------------------------------------------------------------
# gls_coef.m / gen_gls_coef.m — general-least-squares fractional delay FIR
# (Välimäki 1995, ch. 3.2.4)
# --------------------------------------------------------------------------
def gls_coef(mu: np.ndarray | float, L: int, wp: float) -> np.ndarray:
    """FD filter taps for one or many delays; returns shape (len(mu), L)."""
    mu = np.atleast_1d(np.asarray(mu, dtype=float))
    N = L - 1
    D = mu + N / 2 - (0.5 if N % 2 == 1 else 0.0)
    k = np.arange(N + 1)
    P = toeplitz(wp * np.sinc(k * wp))
    p1 = wp * np.sinc((k[:, None] - D[None, :]) * wp)  # (L, n_mu)
    h = solve(P, p1, assume_a="sym")
    return h[::-1, :].T  # flipud, one row per delay


def gen_gls_coef(
    max_sco_on: bool,
    L: int,
    wp: float,
    carrier_freq_offset_hz: float,
    carrier_freq_hz: float,
    samp_clock_hz: float,
    n_tx_packet: int,
    initial_offset: float = 0.0,
) -> tuple[np.ndarray, float]:
    so_hz = samp_clock_hz / carrier_freq_hz * carrier_freq_offset_hz
    delta_xi = so_hz / samp_clock_hz
    if not max_sco_on:
        shifts = delta_xi * np.arange(n_tx_packet) + initial_offset
        return gls_coef(shifts, L, wp), float(shifts[-1])
    shift = delta_xi * n_tx_packet + initial_offset
    return np.repeat(gls_coef(shift, L, wp), n_tx_packet, axis=0), float(shift)


# --------------------------------------------------------------------------
# add_sco_interpolate.m — time-varying fractional-delay filtering
# --------------------------------------------------------------------------
def add_sco_interpolate(x: np.ndarray, coefs: np.ndarray, on: bool) -> np.ndarray:
    """Per-sample filter() with changing taps, state carried over (DF-II transposed).

    With transposed direct form, input sample x[m] contributes coefs[m, k] to
    y[m + k], so the whole loop collapses to a sum of shifted products. The
    MATLAB tail loop feeds zeros, which contribute nothing.
    """
    if not on:
        return x
    n, L = coefs.shape
    y = np.zeros(n + L - 1, dtype=complex)
    for k in range(L):
        y[k : k + n] += coefs[:, k] * x
    # remove transition samples: MATLAB so_filt_tmp(L/2+1 : end-(L/2-1))
    return y[L // 2 : len(y) - (L // 2 - 1)]


# --------------------------------------------------------------------------
# add_phase_noise.m — 1/f phase noise after Kasdin (1995)
# --------------------------------------------------------------------------
def add_phase_noise(
    x: np.ndarray, on: bool, level_dbc_hz: float, fo_hz: float, rng: np.random.Generator
) -> np.ndarray:
    if not on:
        return x
    if level_dbc_hz > 0:
        raise ValueError("Phase noise level should be negative.")
    num = np.sqrt(2 * np.pi * fo_hz * 10 ** (level_dbc_hz / 10))
    if num > 0.1:
        warnings.warn("Current parameters in phase noise block may produce inaccurate results.")
    num_taps = 64
    den = np.zeros(num_taps)
    den[0] = 1.0
    for idx in range(2, num_taps + 1):  # MATLAB 1-based idx
        den[idx - 1] = (idx - 2.5) * den[idx - 2] / (idx - 1)
    noise = rng.standard_normal(x.shape)
    return x * np.exp(1j * lfilter([num], den, noise))
