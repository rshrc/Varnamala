{{flutter_js}}
{{flutter_build_config}}

// Flutter keeps WebKit - Safari, every browser on iOS, and the installed iOS
// app - on the JavaScript build by default, even when the Wasm build is
// deployed. `?wasm=1` opts this browser into Wasm to try it, `?wasm=0` puts it
// back. The choice is remembered per browser. The loader still checks the
// browser's Wasm features first, so an older Safari falls back to JavaScript
// regardless.
let webkitWasm = false;
try {
  const choice = new URLSearchParams(location.search).get('wasm');
  if (choice === '1' || choice === '0') {
    localStorage.setItem('varnamala.webkitWasm', choice);
  }
  webkitWasm = localStorage.getItem('varnamala.webkitWasm') === '1';
} catch (_) {
  // Storage blocked (private browsing): stay on the default.
}

_flutter.loader.load({
  config: webkitWasm ? { wasmAllowList: { webkit: true } } : {},
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
