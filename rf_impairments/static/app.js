"use strict";

const $ = (sel) => document.querySelector(sel);
const form = $("#controls");
const canvas = $("#plot");
const ctx = canvas.getContext("2d");

const MAX_HISTORY = 24;     // packets kept for persistence mode
const SNR_INF = 51;         // slider position meaning "noiseless"
const ANIMATE_MS = 90;

const state = {
  modulation: "BPSK",
  history: [],              // received packets, newest last
  ideal: [],
  packets: 0,
  playing: false,
  busy: false,
  pending: false,
};

// ---------------------------------------------------------------- theme
function storageGet(key) { try { return localStorage.getItem(key); } catch { return null; } }
function storageSet(key, v) { try { localStorage.setItem(key, v); } catch { /* ignore */ } }

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  draw();
}
applyTheme(storageGet("theme") ||
  (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"));
$("#theme").addEventListener("click", () => {
  const next = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
  storageSet("theme", next);
  applyTheme(next);
});

// ---------------------------------------------------------------- controls
async function init() {
  const cfg = await (await fetch("/api/config")).json();

  const tx = $("#transmission");
  for (const [value, label] of Object.entries(cfg.transmissions)) tx.add(new Option(label, value));

  for (const sel of document.querySelectorAll("select.ppm")) {
    for (const v of cfg.ppm_choices) sel.add(new Option(`${v > 0 ? "+" : ""}${v} ppm`, v));
  }

  const seg = $("#modulation");
  for (const m of cfg.modulations) {
    const b = document.createElement("button");
    b.type = "button";
    b.role = "radio";
    b.textContent = m;
    b.setAttribute("aria-checked", m === state.modulation);
    b.addEventListener("click", () => {
      state.modulation = m;
      seg.querySelectorAll("button").forEach((x) => x.setAttribute("aria-checked", x === b));
      onChange();
    });
    seg.append(b);
  }
  updateOutputs();
  run();
}

function snrValue() {
  const v = Number($("#snr").value);
  return v >= SNR_INF ? null : v;
}

function numOrNull(name) {
  const raw = form.elements[name].value.trim();
  if (raw === "") return null;
  const v = Number(raw);
  return Number.isFinite(v) ? v : null;
}

function readForm() {
  const f = form.elements;
  return {
    transmission: f.transmission.value,
    modulation: state.modulation,
    sco_ppm: Number(f.sco_ppm.value),
    cfo_ppm: Number(f.cfo_ppm.value),
    t_offset: Number(f.t_offset.value),
    phase_deg: Number(f.phase_deg.value),
    pn_level: numOrNull("pn_level"),
    pn_fo: numOrNull("pn_fo"),
    amp_imbal: numOrNull("amp_imbal"),
    phs_imbal: numOrNull("phs_imbal"),
    dc_i: numOrNull("dc_i"),
    dc_q: numOrNull("dc_q"),
    snr_db: snrValue(),
    random_data: f.random_data.checked,
  };
}

function updateOutputs() {
  const f = form.elements;
  $("#t_offset_out").textContent = `${Number(f.t_offset.value).toFixed(2)} samples`;
  $("#phase_out").textContent = `${Math.round(f.phase_deg.value)}°`;
  const snr = snrValue();
  $("#snr_out").textContent = snr === null ? "∞ (noiseless)" : `${snr} dB`;
}

// ---------------------------------------------------------------- simulation
async function run() {
  // coalesce requests while one is in flight
  if (state.busy) { state.pending = true; return; }
  state.busy = true;
  try {
    const res = await fetch("/api/simulate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(readForm()),
    });
    if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);
    const data = await res.json();
    $("#error").hidden = true;

    // Like the MATLAB GUI: the end-of-packet time/phase offsets become the
    // starting point of the next run, so repeated runs show the drift.
    const f = form.elements;
    f.t_offset.value = data.t_offset;
    f.phase_deg.value = data.phase_deg;
    for (const [k, v] of Object.entries(data.applied)) {
      if (f[k] && document.activeElement !== f[k]) f[k].value = v;
    }
    updateOutputs();

    state.ideal = data.ideal;
    state.history.push(data.rx);
    if (state.history.length > MAX_HISTORY) state.history.shift();
    state.packets += 1;

    $("#evm").textContent = `${data.evm_percent.toFixed(2)} %`;
    $("#evm_db").textContent = data.evm_db < -200 ? "−∞ dB" : `${data.evm_db.toFixed(1)} dB`;
    $("#stat_t").textContent = data.t_offset.toFixed(4);
    $("#stat_p").textContent = `${data.phase_deg.toFixed(1)}°`;
    $("#stat_n").textContent = state.packets;
    draw();
  } catch (err) {
    $("#error").textContent = `Simulation failed — ${err.message}`;
    $("#error").hidden = false;
    stopPlay();
  } finally {
    state.busy = false;
    if (state.pending) { state.pending = false; run(); }
  }
}

let debounce;
function onChange() {
  updateOutputs();
  if (!$("#autorun").checked || state.playing) return;
  clearTimeout(debounce);
  debounce = setTimeout(run, 120);
}

form.addEventListener("input", onChange);
form.addEventListener("submit", (e) => { e.preventDefault(); run(); });
form.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && e.target.tagName === "INPUT") { e.preventDefault(); run(); }
});
$("#snr").addEventListener("input", onChange);
$("#run").addEventListener("click", run);
$("#persist").addEventListener("change", draw);

// ---------------------------------------------------------------- animate
async function playLoop() {
  while (state.playing) {
    const t0 = performance.now();
    await run();
    const wait = ANIMATE_MS - (performance.now() - t0);
    if (wait > 0) await new Promise((r) => setTimeout(r, wait));
  }
}
function startPlay() {
  state.playing = true;
  $("#play").classList.add("active");
  $("#play span").textContent = "Stop";
  playLoop();
}
function stopPlay() {
  state.playing = false;
  $("#play").classList.remove("active");
  $("#play span").textContent = "Animate";
}
$("#play").addEventListener("click", () => (state.playing ? stopPlay() : startPlay()));

document.addEventListener("keydown", (e) => {
  const tag = document.activeElement?.tagName;
  if (e.code === "Space" && !["INPUT", "SELECT", "BUTTON"].includes(tag)) {
    e.preventDefault();
    state.playing ? stopPlay() : startPlay();
  }
});

$("#reset").addEventListener("click", () => {
  stopPlay();
  form.elements.t_offset.value = 0;
  form.elements.phase_deg.value = 0;
  state.history = [];
  state.packets = 0;
  updateOutputs();
  run();
});

// ---------------------------------------------------------------- plot
function css(name) { return getComputedStyle(document.documentElement).getPropertyValue(name).trim(); }

function draw() {
  const rect = canvas.getBoundingClientRect();
  if (!rect.width) return;
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

  const W = rect.width, H = rect.height;
  const pad = { l: 46, r: 14, t: 14, b: 40 };
  const pw = W - pad.l - pad.r, ph = H - pad.t - pad.b;

  // MATLAB: axis([-1 1 -1 1]*sqrt(2)); widen only if points fall outside
  let lim = Math.SQRT2;
  for (const pkt of state.history) for (const [i, q] of pkt) lim = Math.max(lim, Math.abs(i) * 1.08, Math.abs(q) * 1.08);
  const sx = (x) => pad.l + ((x + lim) / (2 * lim)) * pw;
  const sy = (y) => pad.t + ((lim - y) / (2 * lim)) * ph;

  ctx.clearRect(0, 0, W, H);

  // grid + ticks
  const step = lim > 3 ? 1 : 0.5;
  ctx.font = "11px Inter, Segoe UI, system-ui, sans-serif";
  ctx.fillStyle = css("--muted");
  ctx.lineWidth = 1;
  for (let v = -Math.floor(lim / step) * step; v <= lim + 1e-9; v += step) {
    const x = Math.round(sx(v)) + 0.5, y = Math.round(sy(v)) + 0.5;
    ctx.strokeStyle = Math.abs(v) < 1e-9 ? css("--axis") : css("--grid");
    ctx.beginPath(); ctx.moveTo(x, pad.t); ctx.lineTo(x, pad.t + ph); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(pad.l, y); ctx.lineTo(pad.l + pw, y); ctx.stroke();
    const label = Number(v.toFixed(2)).toString();
    ctx.textAlign = "center"; ctx.textBaseline = "top";
    ctx.fillText(label, x, pad.t + ph + 6);
    ctx.textAlign = "right"; ctx.textBaseline = "middle";
    ctx.fillText(label, pad.l - 7, y);
  }
  ctx.strokeStyle = css("--border");
  ctx.strokeRect(pad.l + 0.5, pad.t + 0.5, pw, ph);

  ctx.textAlign = "center"; ctx.textBaseline = "bottom";
  ctx.fillText("In-phase (I)", pad.l + pw / 2, H - 2);
  ctx.save();
  ctx.translate(11, pad.t + ph / 2); ctx.rotate(-Math.PI / 2);
  ctx.textBaseline = "middle";
  ctx.fillText("Quadrature (Q)", 0, 0);
  ctx.restore();

  // ideal constellation
  ctx.strokeStyle = css("--ideal");
  ctx.lineWidth = 1.5;
  const r = state.ideal.length > 16 ? 5 : 8;
  for (const [i, q] of state.ideal) {
    ctx.beginPath(); ctx.arc(sx(i), sy(q), r, 0, 2 * Math.PI); ctx.stroke();
  }

  // received samples as 'x' markers (MATLAB plot(iqdata,'x'))
  const persist = $("#persist").checked;
  const packets = persist ? state.history : state.history.slice(-1);
  const rx = css("--rx");
  packets.forEach((pkt, idx) => {
    const age = packets.length - 1 - idx;
    ctx.globalAlpha = persist ? Math.max(0.08, 1 - age / MAX_HISTORY) : 1;
    ctx.strokeStyle = rx;
    ctx.lineWidth = 1.6;
    ctx.beginPath();
    for (const [i, q] of pkt) {
      const x = sx(i), y = sy(q), s = 3.5;
      ctx.moveTo(x - s, y - s); ctx.lineTo(x + s, y + s);
      ctx.moveTo(x - s, y + s); ctx.lineTo(x + s, y - s);
    }
    ctx.stroke();
  });
  ctx.globalAlpha = 1;
}

new ResizeObserver(draw).observe(canvas);
init().catch((err) => {
  $("#error").textContent = `Could not reach the backend — ${err.message}`;
  $("#error").hidden = false;
});
