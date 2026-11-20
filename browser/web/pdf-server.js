// pdf-server.js -- a service worker that serves the PDFs the character form makes
//
// The form keeps the newest PDF in the cache `typeset-pdfs` under
// typesetter/pdf/NAME, with the headers a server would send, and opens a
// tab there; this worker answers that request, so that the browser shows
// the PDF and saves it as NAME.  Other requests go to the network.

'use strict';

self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', event => event.waitUntil(self.clients.claim()));

self.addEventListener('fetch', event => {
  if (!event.request.url.startsWith(self.registration.scope + 'pdf/')) return;
  event.respondWith(caches.open('typeset-pdfs')
    .then(cache => cache.match(event.request))
    .then(pdf => pdf || new Response('This PDF is gone; generate it again from the form.',
                                     { status: 404, headers: { 'Content-Type': 'text/plain' } })));
});
