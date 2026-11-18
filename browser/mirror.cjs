// mirror.cjs -- give an Emscripten program run under Node copies of host
// directories, so that it can read and write files as a native program would
'use strict';
const fs = require('fs');
const path = require('path');

// Host directories a command line refers to, as [path, recursive]: the
// current directory, absolute entries of the named search-path variables
// (recursive if they end in //), and the directory named by or holding
// each argument, so that an output file's directory is included.
function directories(args, searchVars = []) {
  const dirs = new Map([[process.cwd(), false]]);
  for (const v of searchVars)
    for (const entry of (process.env[v] || '').split(':'))
      if (entry.startsWith('/')) dirs.set(entry.replace(/\/+$/, ''), entry.endsWith('//'));
  for (const a of args) {
    const p = path.resolve(a.replace(/^-+[a-z-]+=/, ''));
    dirs.set(fs.existsSync(p) && fs.statSync(p).isDirectory() ? p : path.dirname(p), false);
  }
  return [...dirs].filter(([d]) => fs.existsSync(d) && fs.statSync(d).isDirectory());
}

// Copy host directory `from` to `to` in FS; record each file's bytes in `copied`.
function copyIn(FS, from, to, recursive, copied = new Map()) {
  FS.mkdirTree(to);
  for (const name of fs.readdirSync(from)) {
    const [src, dst] = [path.join(from, name), path.posix.join(to, name)];
    const st = fs.statSync(src, { throwIfNoEntry: false });   // follows symbolic links
    if (st && st.isFile()) { const b = fs.readFileSync(src); FS.writeFile(dst, b); copied.set(dst, b); }
    else if (st && st.isDirectory() && recursive) copyIn(FS, src, dst, true, copied);
  }
  return copied;
}

// Write back the files in FS directory `dir` that differ from `copied`.
function copyOut(FS, dir, copied) {
  for (const name of FS.readdir(dir)) {
    const p = path.posix.join(dir, name);
    if (!FS.isFile(FS.stat(p).mode)) continue;
    const b = FS.readFile(p);
    const old = copied.get(p);
    if (!old || Buffer.compare(Buffer.from(b), old) !== 0) fs.writeFileSync(p, b);
  }
}

// Mirror `dirs` into FS, run `body`, and copy changed files back; returns body's result.
function mirrored(FS, dirs, body) {
  const copied = new Map();
  for (const [d, recursive] of dirs) copyIn(FS, d, d, recursive, copied);
  FS.chdir(process.cwd());
  const result = body();
  for (const [d] of dirs) copyOut(FS, d, copied);
  return result;
}

module.exports = { directories, copyIn, mirrored };
