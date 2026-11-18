// generate-pdf.js -- the form's Generate PDF button, typesetting in the browser
//
// Replaces the generatePDF that sends YAML to a server: the YAML goes to
// typeset-worker.js, which starts loading its engines as soon as the
// page loads.  The result opens in a new tab, as the server's did: the
// PDF, or the console output that explains why there is none.

'use strict';
const typesetter = new Worker(new URL('typeset-worker.js', document.currentScript.src));
const waiting = [];   // tabs awaiting results, in request order; null if blocked

typesetter.onmessage = ({ data }) => {
  if (data.status) return console.log('typesetter:', data.status);
  console.log('typesetter timings (ms):', data.timings);
  const tab = waiting.shift();
  const url = URL.createObjectURL(data.pdf || new Blob([data.error], { type: 'text/plain; charset=utf-8' }));
  if (tab) tab.location = url;
  else window.open(url, '_blank');
};

function generatePDF() {
  // A tab opened during the click is not blocked as a pop-up; one opened later may be.
  const tab = window.open('', '_blank');
  if (tab) {
    tab.document.title = 'Typesetting';
    tab.document.body.textContent = 'Typesetting your character sheet…';
  }
  waiting.push(tab);
  typesetter.postMessage({ yaml: createYAMLContent() });
}
