/* 푸시 알림 전용 서비스 워커 (파일 캐시 없음) */
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',e=>e.waitUntil(self.clients.claim()));
self.addEventListener('push',e=>{
  let d={};try{d=e.data.json();}catch(_){}
  e.waitUntil(self.registration.showNotification(d.title||'업무 일정',{
    body:d.body||'',tag:d.tag||'brief',icon:'icons/icon-192.png',badge:'icons/icon-192.png',
    data:{url:d.url||'./?brief=1'}}));
});
self.addEventListener('notificationclick',e=>{
  e.notification.close();
  e.waitUntil((async()=>{
    const all=await clients.matchAll({type:'window',includeUncontrolled:true});
    for(const c of all){if('focus'in c){await c.focus();c.postMessage({brief:1});return;}}
    await clients.openWindow((e.notification.data&&e.notification.data.url)||'./?brief=1');
  })());
});
