const assert = require('node:assert/strict');
const {handle} = require('../community/Bridge/html_ui/InGamePanels/FDRBridge/weather-bridge.js');
(async () => {
 const req={id:'request-1',station:'EPLL',lat:51.72,lon:19.4};
 let calls=[];
 let result=await handle(req,async(name,...args)=>{calls.push([name,...args]);return {icao:'EPLL',metarString:name.includes('METAR')?'EPLL 251200Z 18005KT CAVOK 10/05 Q1013':'',tafString:'TAF EPLL'};});
 assert.equal(result.id,req.id);assert.equal(result.metar.icao,'EPLL');assert.equal(result.taf.icao,'EPLL');assert.equal(calls.length,2);
 result=await handle(req,async name=>name.endsWith('IDENT')?{icao:''}:{icao:'EPWA',metarString:'EPWA nearest'});
 assert.equal(result.metar.icao,'EPWA');
 result=await handle(req,async name=>{if(name.endsWith('IDENT'))throw new Error('Station missing');return {icao:'EPWA'};});
 assert.equal(result.metar.icao,'EPWA');
 result=await handle(req,async()=>{throw new Error('Weather unavailable');});
 assert.equal(result.metar,null);assert.equal(result.taf,null);assert.match(result.metar_error,/unavailable/);
 await assert.rejects(handle({...req,lat:999},async()=>({})),/Invalid/);
 await assert.rejects(handle({...req,station:'../../x'},async()=>({})),/Invalid/);
 console.log('PASS: mock Coherent METAR/TAF, nearest fallback, errors, correlation and request validation. No live simulator.');
})().catch(e=>{console.error(e);process.exitCode=1;});
