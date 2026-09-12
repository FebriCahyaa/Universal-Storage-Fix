"use strict";
const $ = (s) => document.querySelector(s);
const bridge = window.usfBridge;
const safeOps = new Set(["scan", "preview", "apply", "verify", "rollback", "disable"]);
let currentFix = null;
function text(el, value) { el.textContent = String(value ?? "unavailable"); }
async function request(op, payload = {}) {
  if (!safeOps.has(op) || !bridge || typeof bridge.request !== "function") throw new Error("Restricted local bridge is unavailable");
  return bridge.request({op, ...payload});
}
function render(data) {
  const r = data.runtime || {}; const list = $("#runtime"); list.replaceChildren();
  for (const [key, value] of Object.entries(r)) { const dt=document.createElement("dt"),dd=document.createElement("dd"); text(dt,key.replaceAll("_"," ")); text(dd, typeof value === "object" ? JSON.stringify(value) : value); list.append(dt,dd); }
  text($("#diagnostic"), JSON.stringify(data, null, 2));
  const fixes=$("#fixes-list"); fixes.replaceChildren();
  ["refresh_diagnostics","repair_state","clean_temp","rebuild_cache"].forEach(id=>{const b=document.createElement("button"); b.textContent=`Preview ${id}`; b.onclick=()=>preview(id); fixes.append(b);});
}
async function scan() { try { const data=await request("scan"); render(data); text($("#connection"),"Restricted local bridge connected."); } catch(e) { text($("#connection"),e.message); } }
async function preview(id) { try { const p=await request("preview",{fix:id}); currentFix=id; text($("#confirm-text"),`${p.description || id}: ${JSON.stringify(p.changes || [])}`); $("#confirm").showModal(); } catch(e) { alert(e.message); } }
$("#approve").onclick=async()=>{ if (!currentFix) return; try { await request("apply",{fix:currentFix,confirm:true}); await scan(); } catch(e) { alert(e.message); } };
$("#scan").onclick=scan;
fetch("../update.json").then(r=>r.ok?r.json():Promise.reject()).then(x=>text($("#update"),`${x.version} (${x.channel}), API ${x.compatibility.android_api_min}-${x.compatibility.android_api_max}`)).catch(()=>{});
if (bridge) scan();
