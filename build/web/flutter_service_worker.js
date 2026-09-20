'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/favicon-32x32.png": "4cd59e3deba10331ff71c24bf773dc87",
"icons/favicon-16x16.png": "329a95f48edb0fe764da644e136ebeb5",
"icons/site.webmanifest": "053100cb84a50d2ae7f5492f7dd7f25e",
"icons/android-chrome-512x512.png": "d5de52e897b835c73b4ced10b25a7496",
"icons/android-chrome-192x192.png": "db8c4adff8f2dc315b11b78504de126f",
"icons/apple-touch-icon.png": "52969b11731bd84b800b82bbe4d78774",
"manifest.json": "40e55383e907966f5bec0676eea16f2a",
"404.html": "1d13c0c97489a8e8d71fe8888a22d4ac",
"version.json": "66b8531c895e5cbb3b4eba3a81940df4",
"flutter_bootstrap.js": "59340252b47d9c5bdb991f5767264c07",
"index.html": "f94517bac7477a53a0017800cda108d9",
"/": "f94517bac7477a53a0017800cda108d9",
"sqflite_sw.js": "31d56f9d0a4e21949c974394594bb029",
"main.dart.js": "fe06140b0243fa79d369e839dbd9a5f2",
"sqlite3.wasm": "fa7637a49a0e434f2a98f9981856d118",
"assets/AssetManifest.bin": "9bf90fca9b33afe36b96d6c52fe6621f",
"assets/fonts/MaterialIcons-Regular.otf": "ca9f4c2f037bab1d4023e6d599b1a2ea",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/NOTICES": "e8d08c60e419b60079fc9187115941fe",
"assets/AssetManifest.json": "c58b4d0cbe716d497d494a888b2926bd",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/sound/error_tone.mp3": "020d440f85a04577ec073454b1b2974a",
"assets/sound/message/message_send.mp3": "9b958cf3acd845c380b1f424d4495e49",
"assets/sound/message/message_received.mp3": "20898b076cf1242f394a91def61296ee",
"assets/sound/message/notification.mp3": "3f6df726a5e85560dfecf4bb592d2fda",
"assets/sound/success_tone.mp3": "db407b8775a64190cb44dd10be096a97",
"assets/sound/outgoing_call_ring.mp3": "2f9e1a39c0f9ab544a89abc20862ec88",
"assets/sound/connected_tone.mp3": "20898b076cf1242f394a91def61296ee",
"assets/sound/incomming_call_ringtone.mp3": "fef1ed6e178929e379a5f210573adb83",
"assets/sound/end_tone.mp3": "a9ecc128a76ca3388bf1061bdc949f96",
"assets/assets/icons/icons.png": "f5e84074b135e63fc5c790c948505e91",
"assets/assets/logo/logo.png": "a0340e27545afef5b57c7409f8df464f",
"assets/assets/background/bg.jpg": "6d3c3b1651bfba1aa43e223ce7bc9df2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/nepali_date_converter/assets/bs_ad_dates.json": "0a37630647322949ae6606838a9b11bc",
"assets/AssetManifest.bin.json": "c78bd17febb5135351089e0bf333e4b4",
"flutter.js": "383e55f7f3cce5be08fcf1f3881f585c",
"favicon.ico": "2fc645f662edafca1386a15b04ee03de",
"canvaskit/canvaskit.js.symbols": "74a84c23f5ada42fe063514c587968c6",
"canvaskit/skwasm.wasm": "4051bfc27ba29bf420d17aa0c3a98bce",
"canvaskit/canvaskit.wasm": "9251bb81ae8464c4df3b072f84aa969b",
"canvaskit/skwasm.js": "5d4f9263ec93efeb022bb14a3881d240",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"canvaskit/skwasm.js.symbols": "c3c05bd50bdf59da8626bbe446ce65a3",
"canvaskit/canvaskit.js": "738255d00768497e86aa4ca510cce1e1",
"canvaskit/chromium/canvaskit.js.symbols": "ee7e331f7f5bbf5ec937737542112372",
"canvaskit/chromium/canvaskit.wasm": "399e2344480862e2dfa26f12fa5891d7",
"canvaskit/chromium/canvaskit.js": "901bb9e28fac643b7da75ecfd3339f3f"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
