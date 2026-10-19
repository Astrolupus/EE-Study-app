// EE Study Bench service worker: offline-first app shell.
const CACHE='ee-bench-34b5e09a94ea';
const ASSETS=["./", "./fonts/BarlowCondensed-Bold.ttf", "./fonts/BarlowCondensed-SemiBold.ttf", "./fonts/Inter.ttf", "./fonts/JetBrainsMono.ttf", "./fonts/OFL.txt", "./fonts/fonts.css", "./icons/icon-1024.png", "./icons/icon-180.png", "./icons/icon-192.png", "./icons/icon-512.png", "./icons/icon-maskable-512.png", "./index.html", "./manifest.webmanifest"];
self.addEventListener('install',e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting()))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{
  if(e.request.method!=='GET')return;
  e.respondWith(caches.match(e.request,{ignoreSearch:true}).then(hit=>hit||fetch(e.request).catch(()=>caches.match('./index.html'))));
});
