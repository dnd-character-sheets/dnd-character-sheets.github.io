// typeset-worker.js -- typeset character sheets from YAML, in a Web Worker
//
// Message in: { yaml }.  Messages out: { status } while working, then
// either { pdf: Blob, timings } or { error: string, timings }, where the
// error holds the console output of charsheet and TeX.  The engines and
// files load once, when the worker starts, and serve every request;
// each format loads when a sheet first needs it.
//
// Every file NAME this worker loads is served gzipped, so that it
// downloads compressed from any server, under the name that
// manifest.json gives, which includes a hash of its contents: browsers
// may cache it indefinitely, and engines and formats from different
// builds never meet.  The worker asks the server about manifest.json
// every time it starts, and gunzips each file unless the server has.

'use strict';

const say = status => postMessage({ status });

const manifest = fetch('manifest.json', { cache: 'no-cache' }).then(response => {
  if (!response.ok) throw new Error(`manifest.json: ${response.status} ${response.statusText}`);
  return response.json();
});

// contents(NAME): a stream of NAME's bytes
async function contents(name) {
  const response = await fetch((await manifest)[name]);
  if (!response.ok) throw new Error(`${name}: ${response.status} ${response.statusText}`);
  return response.headers.has('Content-Encoding') ? response.body
                                                  : response.body.pipeThrough(new DecompressionStream('gzip'));
}

// fetched(NAME): the bytes of NAME
async function fetched(name) {
  return new Uint8Array(await new Response(await contents(name)).arrayBuffer());
}

// compiled(NAME): the WebAssembly module in NAME, compiled as it downloads
async function compiled(name) {
  const wasm = new Response(await contents(name), { headers: { 'Content-Type': 'application/wasm' } });
  return WebAssembly.compileStreaming(wasm);
}

// imported(NAME): runs the script NAME
async function imported(name) {
  const url = URL.createObjectURL(new Blob([await fetched(name)], { type: 'text/javascript' }));
  importScripts(url);
  URL.revokeObjectURL(url);
}

// untarred(TAR): the regular files in a ustar archive, as [path, bytes] pairs
function untarred(tar) {
  const files = [];
  const field = (o, n) => new TextDecoder().decode(tar.subarray(o, o + n)).replace(/\0[^]*$/, '');
  for (let o = 0; o + 512 <= tar.length && tar[o] !== 0; ) {
    const size = parseInt(field(o + 124, 12), 8);
    const path = [field(o + 345, 155), field(o, 100)].filter(s => s).join('/').replace(/^\.\//, '');
    if ('0\0'.includes(String.fromCharCode(tar[o + 156]))) files.push([path, tar.subarray(o + 512, o + 512 + size)]);
    o += 512 + Math.ceil(size / 512) * 512;
  }
  return files;
}

const formats = {};   // engine -> promise of its format
const format = engine => formats[engine] ??= fetched(`charsheet-${engine}.fmt`);

const started = performance.now();
const assets = (async () => {
  say('loading');
  format('xetex');   // most sheets are typeset by XeTeX
  const [busytexModule, luaModule, charsheet, core] = await Promise.all([
    compiled('busytex.wasm'), compiled('lua.wasm'), fetched('charsheet.lua'), fetched('core.tar'),
    imported('busytex.js'), imported('lua.js'),
  ]);
  return { busytexModule, luaModule, charsheet, files: untarred(core), extras: null,
           loaded: performance.now() - started };
})();

// an Emscripten module made by FACTORY from compiled MODULE, collecting its output in LOG
function instance(factory, module, log, extra = {}) {
  return factory({
    noInitialRun: true,
    instantiateWasm(imports, done) { WebAssembly.instantiate(module, imports).then(i => done(i)); return {}; },
    print: s => log.push(s), printErr: s => log.push(s),
    ...extra,
  });
}

// write each [path, bytes] in FILES under / in FS
function install(FS, files) {
  for (const [path, bytes] of files) {
    FS.mkdirTree('/' + path.replace(/\/[^/]*$/, ''));
    FS.writeFile('/' + path, bytes);
  }
}

// the TeX that charsheet makes from YAML, or null; output goes to LOG
async function sheetTeX(a, yaml, log) {
  const lua = await instance(createLua, a.luaModule, log);
  lua.FS.mkdirTree('/charsheet/bin');
  lua.FS.writeFile('/charsheet/bin/charsheet', a.charsheet);
  install(lua.FS, a.files.filter(([p]) => /^charsheet\/templates\/.*\.tex$/.test(p)));
  lua.FS.mkdirTree('/work');
  lua.FS.writeFile('/work/sheet.yaml', yaml);
  const status = lua.callMain(['/charsheet/bin/charsheet', '-wasm', '-o', '/work/sheet.tex', '/work/sheet.yaml']);
  return status === 0 ? lua.FS.readFile('/work/sheet.tex') : null;
}

// the PDF that TeX makes from TEX, or null; output goes to LOG
async function sheetPDF(a, tex, log) {
  const engine = tex.some(b => b >= 0x80) ? 'xetex' : 'pdftex';   // as bin/charsheet chooses
  const tx = await instance(busytex, a.busytexModule, log, {
    thisProgram: '/bin/busytex',
    preRun: [M => Object.assign(M.ENV, {   // the environment is fixed at startup
      TEXMFCNF: '/texmf/web2c', TEXMF: '/texmf', TEXMFDBS: '', TEXMFVAR: '/tmp/texmf-var',
      TEXINPUTS: '.:/charsheet/templates//:', TEXFORMATS: '/formats',
      FONTCONFIG_PATH: '/texmf/fonts/conf',
    })],
  });
  const FS = tx.FS;
  FS.mkdirTree('/bin'); FS.writeFile('/bin/busytex', '');   // kpathsea looks for the program's directory
  install(FS, a.files);
  if (a.extras) install(FS, a.extras);
  FS.mkdirTree('/formats'); FS.writeFile(`/formats/charsheet-${engine}.fmt`, await format(engine));
  FS.mkdirTree('/work'); FS.chdir('/work');
  FS.writeFile('/work/sheet.tex', tex);
  const flags = ['-interaction=nonstopmode', '-halt-on-error', '-no-shell-escape'];
  const runs = {
    pdftex: [['pdftex', '-progname=pdflatex', '-fmt=charsheet-pdftex', ...flags, 'sheet.tex']],
    xetex: [['xetex', '-progname=xelatex', '-fmt=charsheet-xetex', ...flags, '-no-pdf', 'sheet.tex'],
            ['xdvipdfmx', '-q', '-o', 'sheet.pdf', 'sheet.xdv']],
  }[engine];
  const failed = runs.some(args => tx.callMain(args) !== 0);
  return !failed && FS.analyzePath('/work/sheet.pdf').exists ? FS.readFile('/work/sheet.pdf') : null;
}

// Requests run one at a time, in order.
let queue = Promise.resolve();
onmessage = ({ data }) => { queue = queue.then(() => typeset(data.yaml)); };

// An engine may throw outside any promise chain; crash fails the current request.
let crash = () => {};
addEventListener('error', e => crash(e.error || e.message));
addEventListener('unhandledrejection', e => crash(e.reason));

async function typeset(yaml) {
  const timings = {};
  const log = [];
  const crashed = new Promise((_, reject) => { crash = reject; });
  try {
    postMessage(await Promise.race([result(yaml, log, timings), crashed]));
  } catch (e) {
    postMessage({ error: [...log, String(e && e.stack || e)].join('\n'), timings });
  }
}

// the reply to a request for YAML: { pdf, timings } or { error, timings }
async function result(yaml, log, timings) {
  const t0 = performance.now();
  const a = await assets;
  timings.load = a.loaded;
  say('converting YAML');
  const tex = await sheetTeX(a, yaml, log);
  timings.lua = performance.now() - t0;
  if (!tex) return { error: log.join('\n'), timings };
  say('typesetting');
  let pdf = await sheetPDF(a, tex, log);
  if (!pdf && !a.extras) {   // perhaps a font that only the extras hold
    say('loading more fonts');
    a.extras = untarred(await fetched('extras.tar'));
    log.push('', '--- again, with more fonts ---', '');
    pdf = await sheetPDF(a, tex, log);
  }
  timings.total = performance.now() - t0;
  return pdf ? { pdf: new Blob([pdf], { type: 'application/pdf' }), timings }
             : { error: log.join('\n'), timings };
}
