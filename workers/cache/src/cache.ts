export default {
  async fetch(request, env, context) {
    try {
      const url = new URL(request.url);
      const cacheKey = new Request(url.toString(), request);
      const cache = caches.default;

      let response = await cache.match(cacheKey);

      if (response) {
        console.log(`Cache hit for: ${request.url}.`);
        return response;
      }

      console.log(
        `Response for request url: ${request.url} not present in cache. Fetching and caching request.`
      );

      const objectKey = url.pathname.slice(1);
      const object = await env.R2_STORE.get(objectKey);
      if (object === null) {
        return new Response("Object Not Found", { status: 404 });
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("etag", object.httpEtag);
      headers.set("Cache-Control", "s-maxage=84000");
      headers.set("Cache-Control", "max-age=14400");
      headers.append("Cache-Control", "stale-if-error=400");

      headers.append("Cloudflare-CDN-Cache-Control", "stale-if-error=60");
      headers.append("CDN-Cache-Control", "stale-if-error=200");

      headers.append("Cloudflare-CDN-Cache-Control", "max-age=24400");
      headers.append("CDN-Cache-Control", "max-age=18000");

      response = new Response(object.body, {
        headers,
      });

      context.waitUntil(cache.put(cacheKey, response.clone()));

      return response;
    } catch (e) {
      return new Response("Error thrown " + e.message);
    }
  },
};
