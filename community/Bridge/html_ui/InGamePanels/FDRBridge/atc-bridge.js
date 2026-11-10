/* Receive only: never selects ATC options or transmits radio messages. */
(function(root){
 "use strict";
 function lineText(args){
  const lines=[];
  function take(v){
   if(typeof v==='string' && v.trim()) lines.push(v.trim());
   else if(v && typeof v==='object'){
    for(const key of ['text','Text','message','Message','line','Line','content','Content'])
     if(typeof v[key]==='string' && v[key].trim()) { lines.push(v[key].trim()); break; }
   }
  }
  args.forEach(take);
  return lines.join(' ').replace(/<[^>]*>/g,'').slice(0,8192);
 }
 root.FDRATCBridge={lineText};
 if(typeof module!=='undefined') module.exports={lineText};
 if(typeof document==='undefined') return;
 const queue=[],session=Date.now().toString(36)+'-'+Math.random().toString(36).slice(2);
 let seq=0,listener;
 async function flush(){
  try{
   if(queue.length){
    const controller=new AbortController(),timer=setTimeout(()=>controller.abort(),2500);
    try{
     const response=await fetch('http://127.0.0.1:'+(root.FDRBridgePort||19787)+'/atc/messages',{
      method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(queue[0]),signal:controller.signal});
     if(response.ok || response.status===400 || response.status===413) queue.shift();
    }finally{clearTimeout(timer);}
   }
  }catch(e){ /* Keep bounded queue until recorder is available. */ }
  finally{setTimeout(flush,100);}
 }
 window.addEventListener('load',()=>{
  try{
   listener=RegisterViewListener('JS_LISTENER_ATC',()=>{},true);
   listener.on('ATCDialogLine',(...args)=>{
    let raw;try{raw=JSON.stringify(args);}catch(e){return;}
    if(raw.length>24000) return;
    if(queue.length===256) queue.shift();
    queue.push({id:session+':'+(++seq),event:'ATCDialogLine',captured_utc:new Date().toISOString(),text:lineText(args),raw:args});
   });
  }catch(e){console.warn('FDR ATC listener unavailable',e);}
  flush();
 });
})(typeof window==='undefined'?globalThis:window);
