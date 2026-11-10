/* Read-only MSFS weather bridge. No flight controls or simulator settings are changed. */
(function (root) {
  "use strict";
  const timeout = (promise, ms) => new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error("Simulator weather request timed out")), ms);
    Promise.resolve(promise).then(v => { clearTimeout(timer); resolve(v); }, e => { clearTimeout(timer); reject(e); });
  });
  async function getWeather(call, kind, req) {
    let report = null, error = "";
    const valid = r => r && typeof r === "object" && /^[A-Z0-9]{4}$/.test(r.icao || "");
    try { report = await timeout(call("GET_" + kind + "_BY_IDENT", req.station), 6000); }
    catch (e) { error = String(e.message || e); }
    if (!valid(report)) {
      try { report = await timeout(call("GET_" + kind + "_BY_LATLON", req.lat, req.lon), 6000); }
      catch (e) { error = String(e.message || e); }
    }
    if (!valid(report)) { report = null; error = error || "No simulator " + kind + " available"; }
    else error = "";
    return { report, error };
  }
  async function handle(req, call) {
    if (!req || typeof req.id !== "string" || req.id.length > 80 || !/^[A-Z0-9]{4}$/.test(req.station) ||
        !Number.isFinite(req.lat) || Math.abs(req.lat) > 90 || !Number.isFinite(req.lon) || Math.abs(req.lon) > 180) throw new Error("Invalid weather request");
    const pair = await Promise.all([getWeather(call, "METAR", req), getWeather(call, "TAF", req)]);
    return { id: req.id, metar: pair[0].report, taf: pair[1].report, metar_error: pair[0].error, taf_error: pair[1].error };
  }
  root.FDRBridgeBridge = { handle };
  if (typeof module !== "undefined") module.exports = { handle };
  if (typeof document === "undefined") return;
  const base = "http://127.0.0.1:" + (root.FDRBridgePort || 19787), completed = new Map();
  const status = text => { const el = document.getElementById("bridge-status"); if (el) el.textContent = text; };
  let ready = false, listener;
  async function poll() {
    try {
      if (!ready) { status("Waiting for MSFS facility listener..."); return; }
      const controller = typeof AbortController === "undefined" ? null : new AbortController();
      const timer = controller ? setTimeout(() => controller.abort(), 2500) : null;
      let response;
      try { response = await timeout(fetch(base + "/weather/requests", { cache: "no-store", signal: controller ? controller.signal : undefined }), 3000); }
      finally { if (timer) clearTimeout(timer); }
      if (!response.ok) throw new Error("Recorder HTTP " + response.status);
      const requests = await response.json();
      if (!Array.isArray(requests) || requests.length > 16) throw new Error("Invalid recorder queue");
      const active = new Set(requests.map(r => r.id));
      for (const id of completed.keys()) if (!active.has(id)) completed.delete(id);
      await Promise.all(requests.map(async request => {
        if (!completed.has(request.id)) completed.set(request.id, await handle(request, (...args) => Coherent.call(...args)));
        const result = await timeout(fetch(base + "/weather/responses", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(completed.get(request.id)) }), 3000);
        if (result.ok || result.status === 410) completed.delete(request.id);
        else throw new Error("Recorder response HTTP " + result.status);
      }));
      status("Connected to MSFS24-FDR. Weather requests processed: " + requests.length);
    } catch (e) { status("Recorder unavailable: " + String(e.message || e)); }
    finally { setTimeout(poll, 1000); }
  }
  window.addEventListener("load", () => {
    try { listener = RegisterViewListener("JS_LISTENER_FACILITY", () => { setTimeout(() => { ready = true; }, 2000); }, true); }
    catch (e) { status(String(e)); }
    poll();
  });
})(typeof window === "undefined" ? globalThis : window);
