// This is a service worker for the Flutter web app.
// It handles caching and offline functionality.

const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/": [
    "index.html",
    "main.dart.js",
    "assets/AssetManifest.json",
    "assets/FontManifest.json",
    "assets/NOTICES",
    "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf",
    "assets/fonts/MaterialIcons-Regular.otf",
    "assets/fonts/MaterialIcons-Regular.ttf",
    "assets/fonts/MaterialIcons-Regular.woff",
    "assets/fonts/MaterialIcons-Regular.woff2",
    "assets/fonts/MaterialIcons_Regular.otf",
    "assets/fonts/MaterialIcons_Regular.ttf",
    "assets/fonts/MaterialIcons_Regular.woff",
    "assets/fonts/MaterialIcons_Regular.woff2",
    "assets/fonts/MaterialIcons_Sharp-Regular.otf",
    "assets/fonts/MaterialIcons_Sharp-Regular.ttf",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff2",
    "assets/fonts/MaterialIcons_Sharp.otf",
    "assets/fonts/MaterialIcons_Sharp.ttf",
    "assets/fonts/MaterialIcons_Sharp.woff",
    "assets/fonts/MaterialIcons_Sharp.woff2",
    "assets/fonts/MaterialIcons_TwoTone.otf",
    "assets/fonts/MaterialIcons_TwoTone.ttf",
    "assets/fonts/MaterialIcons_TwoTone.woff",
    "assets/fonts/MaterialIcons_TwoTone.woff2",
    "assets/fonts/MaterialIcons_TwoTone-Regular.otf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.ttf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff2",
    "assets/fonts/MaterialIconsOutlined-Regular.otf",
    "assets/fonts/MaterialIconsOutlined-Regular.ttf",
    "assets/fonts/MaterialIconsOutlined-Regular.woff",
    "assets/fonts/MaterialIconsOutlined-Regular.woff2",
    "assets/fonts/MaterialIconsOutlined.otf",
    "assets/fonts/MaterialIconsOutlined.ttf",
    "assets/fonts/MaterialIconsOutlined.woff",
    "assets/fonts/MaterialIconsOutlined.woff2",
    "assets/fonts/MaterialIconsRounded-Regular.otf",
    "assets/fonts/MaterialIconsRounded-Regular.ttf",
    "assets/fonts/MaterialIconsRounded-Regular.woff",
    "assets/fonts/MaterialIconsRounded-Regular.woff2",
    "assets/fonts/MaterialIconsRounded.otf",
    "assets/fonts/MaterialIconsRounded.ttf",
    "assets/fonts/MaterialIconsRounded.woff",
    "assets/fonts/MaterialIconsRounded.woff2",
    "assets/fonts/MaterialIcons_Outlined-Regular.otf",
    "assets/fonts/MaterialIcons_Outlined-Regular.ttf",
    "assets/fonts/MaterialIcons_Outlined-Regular.woff",
    "assets/fonts/MaterialIcons_Outlined-Regular.woff2",
    "assets/fonts/MaterialIcons_Outlined.otf",
    "assets/fonts/MaterialIcons_Outlined.ttf",
    "assets/fonts/MaterialIcons_Outlined.woff",
    "assets/fonts/MaterialIcons_Outlined.woff2",
    "assets/fonts/MaterialIcons_Rounded-Regular.otf",
    "assets/fonts/MaterialIcons_Rounded-Regular.ttf",
    "assets/fonts/MaterialIcons_Rounded-Regular.woff",
    "assets/fonts/MaterialIcons_Rounded-Regular.woff2",
    "assets/fonts/MaterialIcons_Rounded.otf",
    "assets/fonts/MaterialIcons_Rounded.ttf",
    "assets/fonts/MaterialIcons_Rounded.woff",
    "assets/fonts/MaterialIcons_Rounded.woff2",
    "assets/fonts/MaterialIcons_Sharp.otf",
    "assets/fonts/MaterialIcons_Sharp.ttf",
    "assets/fonts/MaterialIcons_Sharp.woff",
    "assets/fonts/MaterialIcons_Sharp.woff2",
    "assets/fonts/MaterialIcons_Sharp-Regular.otf",
    "assets/fonts/MaterialIcons_Sharp-Regular.ttf",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff2",
    "assets/fonts/MaterialIcons_TwoTone.otf",
    "assets/fonts/MaterialIcons_TwoTone.ttf",
    "assets/fonts/MaterialIcons_TwoTone.woff",
    "assets/fonts/MaterialIcons_TwoTone.woff2",
    "assets/fonts/MaterialIcons_TwoTone-Regular.otf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.ttf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff2",
    "assets/fonts/MaterialIconsOutlined-Regular.otf",
    "assets/fonts/MaterialIconsOutlined-Regular.ttf",
    "assets/fonts/MaterialIconsOutlined-Regular.woff",
    "assets/fonts/MaterialIconsOutlined-Regular.woff2",
    "assets/fonts/MaterialIconsOutlined.otf",
    "assets/fonts/MaterialIconsOutlined.ttf",
    "assets/fonts/MaterialIconsOutlined.woff",
    "assets/fonts/MaterialIconsOutlined.woff2",
    "assets/fonts/MaterialIconsRounded-Regular.otf",
    "assets/fonts/MaterialIconsRounded-Regular.ttf",
    "assets/fonts/MaterialIconsRounded-Regular.woff",
    "assets/fonts/MaterialIconsRounded-Regular.woff2",
    "assets/fonts/MaterialIconsRounded.otf",
    "assets/fonts/MaterialIconsRounded.ttf",
    "assets/fonts/MaterialIconsRounded.woff",
    "assets/fonts/MaterialIconsRounded.woff2",
    "assets/fonts/MaterialIcons_Outlined-Regular.otf",
    "assets/fonts/MaterialIcons_Outlined-Regular.ttf",
    "assets/fonts/MaterialIcons_Outlined-Regular.woff",
    "assets/fonts/MaterialIcons_Outlined-Regular.woff2",
    "assets/fonts/MaterialIcons_Outlined.otf",
    "assets/fonts/MaterialIcons_Outlined.ttf",
    "assets/fonts/MaterialIcons_Outlined.woff",
    "assets/fonts/MaterialIcons_Outlined.woff2",
    "assets/fonts/MaterialIcons_Rounded-Regular.otf",
    "assets/fonts/MaterialIcons_Rounded-Regular.ttf",
    "assets/fonts/MaterialIcons_Rounded-Regular.woff",
    "assets/fonts/MaterialIcons_Rounded-Regular.woff2",
    "assets/fonts/MaterialIcons_Rounded.otf",
    "assets/fonts/MaterialIcons_Rounded.ttf",
    "assets/fonts/MaterialIcons_Rounded.woff",
    "assets/fonts/MaterialIcons_Rounded.woff2",
    "assets/fonts/MaterialIcons_Sharp.otf",
    "assets/fonts/MaterialIcons_Sharp.ttf",
    "assets/fonts/MaterialIcons_Sharp.woff",
    "assets/fonts/MaterialIcons_Sharp.woff2",
    "assets/fonts/MaterialIcons_Sharp-Regular.otf",
    "assets/fonts/MaterialIcons_Sharp-Regular.ttf",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff",
    "assets/fonts/MaterialIcons_Sharp-Regular.woff2",
    "assets/fonts/MaterialIcons_TwoTone.otf",
    "assets/fonts/MaterialIcons_TwoTone.ttf",
    "assets/fonts/MaterialIcons_TwoTone.woff",
    "assets/fonts/MaterialIcons_TwoTone.woff2",
    "assets/fonts/MaterialIcons_TwoTone-Regular.otf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.ttf",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff",
    "assets/fonts/MaterialIcons_TwoTone-Regular.woff2"
  ]
};

const CORE = [
  "/",
  "main.dart.js",
  "index.html",
  "assets/AssetManifest.json",
  "assets/FontManifest.json"
];

// Install event - cache core assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(CORE);
    })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event - serve from cache, falling back to network
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
