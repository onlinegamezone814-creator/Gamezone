// Online Game Zone: makes the site installable and keeps the home page working with a weak connection.
const CACHE = "ogz-v1";
self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(["/", "/icon-192.png"])).catch(() => {}));
  self.skipWaiting();
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const r = e.request;
  if (r.method !== "GET") return;
  const u = new URL(r.url);
  if (u.origin !== location.origin) return;                       // never touch Supabase, tawk.to, etc.
  if (r.mode === "navigate") {
    if (u.pathname !== "/" && u.pathname !== "/index.html") return; // admin.html and other pages are not cached
    // always try the network first, so a new version of the site shows up right away
    e.respondWith(fetch(r).then(res => { const copy = res.clone(); caches.open(CACHE).then(c => c.put("/", copy)); return res; })
      .catch(() => caches.match("/")));
    return;
  }
  e.respondWith(caches.match(r).then(m => m || fetch(r).then(res => { if (res.ok) { const copy = res.clone(); caches.open(CACHE).then(c => c.put(r, copy)); } return res; })));
});
