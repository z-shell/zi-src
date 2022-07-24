export default {
  async fetch(request, env, context) {
    try {
      const cacheUrl = new URL(request.url);
      const cacheKey = new Request(cacheUrl.toString(), request);
      const cache = caches.default;

      let response = await cache.match(cacheKey);

      if (!response) {
        console.log(
          `Response for request url: ${request.url} not present in cache. Fetching and caching request.`
        );
        response = await fetch(request);
        response = new Response(response.body, response);
        response.headers.append("Cache-Control", "s-maxage=60");

        context.waitUntil(cache.put(cacheKey, response.clone()));
      } else {
        console.log(`Cache hit for: ${request.url}.`);
      }
      return response;
    } catch (e) {
      return new Response("Error thrown " + e.message);
    }
  },
};
