/* Passive checklist snapshots. Native service contract: JS/Services/checklistManager.js. */
(function (root) {
 "use strict";
 function text(value) {
  if (typeof value !== 'string') return '';
  if (root.Utils && typeof root.Utils.Translate === 'function') value = root.Utils.Translate(value);
  return value.replace(/<[^>]*>/g, '').trim().slice(0, 4096);
 }
 function label(value) {
  for (const key of ['sName','sTitle','sDesc','sDescription','name','title','description']) {
   const result = text(value[key]);
   if (result) return result;
  }
  return '';
 }
 function id(value, page) {
  for (const key of page ? ['nPageId','nId','id'] : ['nCheckpointId','nId','id'])
   if (value[key] !== undefined && value[key] !== null) return String(value[key]);
  return '';
 }
 function checked(value) {
  let found = false, result = false;
  for (const key of ['bChecked','bIsChecked','bCompleted','bIsComplete','bIsCompleted','bManualChecked','bManualCheck','bValidated','bIsValidated','checked','completed'])
   if (typeof value[key] === 'boolean') { found = true; result = result || value[key]; }
  return found ? result : null;
 }
 function createState() {
  let definition = null, signature = '', evaluation = {}, revision = 0;
  const completion = new Map();
  function updateCompletion(node, page, checkpointArray) {
   if (!node || typeof node !== 'object') return;
   if (Array.isArray(node)) { node.forEach(item => updateCompletion(item, page, checkpointArray)); return; }
   const pageId = node.nPageId !== undefined ? String(node.nPageId) : page;
   const checkpointId = node.nCheckpointId !== undefined ? String(node.nCheckpointId) : checkpointArray ? id(node, false) : '';
   const state = checked(node);
   if (pageId !== '' && checkpointId !== '' && state !== null) completion.set(pageId + '/' + checkpointId, state);
   for (const key of Object.keys(node)) {
    const child = node[key];
    if (child && typeof child === 'object') {
     if ((key === 'aPages' || key === 'pages') && Array.isArray(child))
      child.forEach(item => updateCompletion(item, id(item, true), false));
     else updateCompletion(child, pageId, key === 'aCheckpoints' || key === 'checkpoints');
    }
   }
  }
  function apply(event, data) {
   if (event === 'ChecklistWholeData' && data === null) { definition = null; signature = ''; completion.clear(); evaluation = {}; revision++; return true; }
   if (!data || typeof data !== 'object') return false;
   if (event === 'ChecklistWholeData') {
    const next = data.oChecklist || data.oChecklistData || data;
    const nextSignature = JSON.stringify(next);
    if (nextSignature !== signature) { completion.clear(); evaluation = {}; signature = nextSignature; }
    definition = next;
    updateCompletion(data.oCompletion || data, '', false);
    if (data.oEvaluation) evaluation = data.oEvaluation;
   } else if (event === 'ChecklistCompletion') updateCompletion(data, '', false);
   else if (event === 'ChecklistEvaluation') evaluation = data;
   revision++;
   return true;
  }
  function snapshot() {
   const lists = [];
   function walk(node, path, depth) {
    if (!node || typeof node !== 'object' || depth > 16 || lists.length >= 256) return;
    if (Array.isArray(node)) { node.forEach((child, i) => walk(child, path + '.' + i, depth + 1)); return; }
    const items = node.aCheckpoints || node.checkpoints;
    if (Array.isArray(items)) {
     const pageId = id(node, true) || path;
     const rows = [];
     function add(item, itemPath) {
      if (!item || typeof item !== 'object' || rows.length >= 4096) return;
      const nested = item.aCheckpoints || item.checkpoints;
      if (Array.isArray(nested)) { nested.forEach((child, i) => add(child, itemPath + '.' + i)); return; }
      const checkpointId = id(item, false) || itemPath;
      const subject = text(item.sSubject || item.subject) || label(item);
      const expectation = text(item.sExpectation || item.expectation || item.sValue || item.value);
      if (!subject && !expectation) return;
      const key = pageId + '/' + checkpointId;
      rows.push({id:checkpointId,text:subject + (expectation ? ' — ' + expectation : ''),checked:completion.has(key) ? completion.get(key) : checked(item)});
     }
     items.forEach((item, i) => add(item, String(i)));
     lists.push({id:pageId,name:label(node) || pageId,items:rows});
     return;
    }
    for (const key of Object.keys(node))
     if (node[key] && typeof node[key] === 'object') walk(node[key], path + '.' + key, depth + 1);
   }
   walk(definition, 'root', 0);
   return {schema:1,checklists:lists,activeChecklistId:evaluation.nCurrentPageId === undefined ? '' : String(evaluation.nCurrentPageId)};
  }
  return {apply,snapshot,get revision(){return revision;}};
 }
 root.FDRChecklistBridge = {createState};
 if (typeof module !== 'undefined') module.exports = {createState};
 if (typeof document === 'undefined') return;
 const state = createState(), session = Date.now().toString(36) + '-' + Math.random().toString(36).slice(2);
 let listener, sequence = 0;
 async function publish() {
  try {
   if (state.revision) {
    const payload = Object.assign(state.snapshot(), {session,captured_utc:new Date().toISOString(),sequence:++sequence});
    const body = JSON.stringify(payload);
    if (new Blob([body]).size <= 2097152) {
     const abort = new AbortController(), timer = setTimeout(() => abort.abort(), 2500);
     try { await fetch('http://127.0.0.1:' + (root.FDRBridgePort || 19787) + '/checklists/state',
      {method:'POST',headers:{'Content-Type':'application/json'},body,signal:abort.signal}); }
     finally { clearTimeout(timer); }
    }
   }
  } catch (error) { /* The next heartbeat publishes the most recent complete state. */ }
  finally { setTimeout(publish, 500); }
 }
 window.addEventListener('load', () => {
  try {
   // The native ChecklistListener subscribes to Coherent events, not listener.on.
   for (const event of ['ChecklistWholeData','ChecklistCompletion','ChecklistEvaluation'])
    Coherent.on(event, data => { try { state.apply(event, data); } catch (error) { console.warn('FDR checklist data', error); } });
   listener = RegisterViewListener('JS_LISTENER_CHECKLIST', () => {}, true);
  } catch (error) { console.warn('FDR checklist listener unavailable', error); }
  publish();
 });
})(typeof window === 'undefined' ? globalThis : window);
