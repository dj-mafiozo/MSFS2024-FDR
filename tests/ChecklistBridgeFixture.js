// Input/output fixture only. Assertions are owned by VerifyChecklists.dpr (DUnitX).
const fs = require('fs');
const vm = require('vm');
const source = fs.readFileSync(require('path').join(__dirname,'../community/Bridge/html_ui/InGamePanels/FDRBridge/checklist-bridge.js'),'utf8');
const handlers = {}, subscriptions = [], sent = [];
let onload;
const window = {addEventListener:(event,callback)=>{if(event==='load')onload=callback;}};
const context = {window,document:{},globalThis:window,console,Date,Math,Map,JSON,Blob,AbortController,
 Coherent:{on:(name,fn)=>{handlers[name]=fn;}},
 RegisterViewListener:(name)=>{subscriptions.push(name);return {};},
 setTimeout:()=>1,clearTimeout:()=>{},fetch:async(url,options)=>{sent.push({url,body:JSON.parse(options.body)});return {};}};
vm.runInNewContext(source,context);
const model = window.FDRChecklistBridge.createState();
const definition = {aPages:[{nId:7,sName:'BEFORE START',aCheckpoints:[{nCheckpointId:10,sSubject:'Parking brake',sExpectation:'SET'},{nCheckpointId:11,sSubject:'Doors',bChecked:false}]}]};
model.apply('ChecklistWholeData',definition);
const unknown = model.snapshot();
model.apply('ChecklistCompletion',{aPages:[{nId:7,aCheckpoints:[{nCheckpointId:10,bChecked:true}]}]});
model.apply('ChecklistEvaluation',{nCurrentPageId:7});
const complete = model.snapshot();
model.apply('ChecklistCompletion',{nPageId:7,nCheckpointId:10,bChecked:false});
const unchecked = model.snapshot();
model.apply('ChecklistWholeData',{aPages:[{nId:8,sName:'AFTER LANDING',aCheckpoints:[{nCheckpointId:10,sSubject:'Lights'}]}]});
const aircraftChanged = model.snapshot();
model.apply('ChecklistWholeData',null);
const cleared = model.snapshot();
onload();
fs.writeFileSync(process.argv[2],JSON.stringify({unknown,complete,unchecked,aircraftChanged,cleared,subscriptions,events:Object.keys(handlers),sent}));
