function parseRange(
  encoded: string | null
): undefined | { offset: number; length: number } {
  if (encoded === null) {
    return;
  }

  const parts = encoded.split("bytes=")[1]?.split("-") ?? [];
  if (parts.length !== 2) {
    throw new Error(
      "Not supported to skip specifying the beginning/ending byte at this time"
    );
  }

  return {
    offset: Number(parts[0]),
    length: Number(parts[1]) + 1 - Number(parts[0]),
  };
}

function objectNotFound(objectName: string): Response {
  return new Response(
    `<html><body style="background-color:black; color:white"><h3 style="text-align:center">R2 object "<b>${objectName}</b>" not found</h3></body></html>`,
    {
      status: 404,
      headers: {
        "content-type": "text/html; charset=UTF-8",
      },
    }
  );
}

export default {
  async fetch(request: Request, env): Promise<Response> {
    const url = new URL(request.url);
    const objectName = url.pathname.slice(1);

    console.log(`${request.method} object ${objectName}: ${request.url}`);

    if (request.method === "GET" || request.method === "HEAD") {
      if (objectName === "") {
        if (request.method == "HEAD") {
          return new Response(undefined, { status: 400 });
        }

        const options: R2ListOptions = {
          prefix: url.searchParams.get("prefix") ?? undefined,
          delimiter: url.searchParams.get("delimiter") ?? undefined,
          cursor: url.searchParams.get("cursor") ?? undefined,
          include: ["customMetadata", "httpMetadata"],
        };
        console.log(JSON.stringify(options));

        const listing = await env.R2_STORE.list(options);
        return new Response(JSON.stringify(listing), {
          headers: {
            "content-type": "application/json; charset=UTF-8",
          },
        });
      }

      if (request.method === "GET") {
        const range = parseRange(request.headers.get("range"));
        const object = await env.R2_STORE.get(objectName, {
          range,
          onlyIf: request.headers,
        });

        if (object === null) {
          return objectNotFound(objectName);
        }

        const headers = new Headers();
        object.writeHttpMetadata(headers);
        headers.set("etag", object.httpEtag);
        /** headers.append("Access-Control-Allow-Headers", "Content-Type, Set-Cookie, Cache-Control");
        headers.append("Access-Control-Allow-Methods", "GET, HEAD, POST, PUT, DELETE, OPTIONS");
        headers.append("Access-Control-Allow-Origin", "htt");
        headers.append("Access-Control-Max-Age", "600");
        headers.append("Vary", "Origin, Accept-Encoding"); */

        const status = object.body ? (range ? 206 : 200) : 304;
        return new Response(object.body, {
          headers,
          status,
        });
      }

      const object = await env.R2_STORE.head(objectName);

      if (object === null) {
        return objectNotFound(objectName);
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("etag", object.httpEtag);
      return new Response(null, {
        headers,
      });
    }

    /**
    if (request.method === "PUT" || request.method == "POST") {
      const object = await env.R2_STORE.put(objectName, request.body, {
        httpMetadata: request.headers,
      });
      return new Response(null, {
        headers: {
          etag: object.httpEtag,
        },
      });
    }
    if (request.method === "DELETE") {
      await env.R2_STORE.delete(url.pathname.slice(1));
      return new Response();
    }
    */
    return new Response(`Unsupported method`, {
      status: 400,
    });
  },
};
