addEventListener("fetch", (event) => {
  event.respondWith(handleRequest(event));
});

const ASSET_PATH = "z-shell/zi-src/main";
const HOST_URL = `https://raw.githubusercontent.com/z-shell/zi-src/${ASSET_PATH}`;

async function serveAsset(event: FetchEvent) {
  const url = new URL(event.request.url);
  const cache = caches.default;
  let response = await cache.match(event.request);

  if (!response) {
    response = await fetch(`${HOST_URL}${url.pathname}`);
    const headers = { "cache-control": "public, max-age=14400" };
    response = new Response(response.body, { ...response, headers });
    event.waitUntil(cache.put(event.request, response.clone()));
  }
  return response;
}

async function handleRequest(event: FetchEvent) {
  if (event.request.method === "GET") {
    let response = await serveAsset(event);
    if (response.status > 399) {
      response = new Response(response.statusText, { status: response.status });
    }
    return response;
  } else {
    return new Response("Method not allowed", { status: 405 });
  }
}

export {};
