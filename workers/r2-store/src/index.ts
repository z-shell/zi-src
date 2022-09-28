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

function objectNotFound(key: string): Response {
  return new Response(
    `<html><body style="background-color:black; color:white"><h3 style="text-align:center">R2 object "<b>${key}</b>" not found</h3></body></html>`,
    {
      status: 404,
      headers: {
        "content-type": "text/html; charset=UTF-8",
      },
    }
  );
}

const hasValidHeader = (
  request: { headers: { get: (arg0: string) => any } },
  env: { AUTH_KEY_SECRET: any }
) => {
  return request.headers.get("X-Custom-Auth-Key") === env.AUTH_KEY_SECRET;
};

function authorizeRequest(request: Request, env: any) {
  switch (request.method) {
    case "PUT":
    case "DELETE":
      return hasValidHeader(request, env);
    case "GET":
      return true;
    default:
      return false;
  }
}

export default {
  async fetch(
    request: Request,
    env: {
      R2_STORE: {
        list: (arg0: R2ListOptions) => any;
        get: (
          arg0: string,
          arg1: {
            range: { offset: number; length: number } | undefined;
            onlyIf: Headers;
          }
        ) => any;
        head: (arg0: string) => any;
        put: (
          arg0: string,
          arg1: ReadableStream | null,
          arg2: { httpMetadata: Headers }
        ) => any;
        delete: (arg0: string) => any;
      };
    }
  ): Promise<Response> {
    const url = new URL(request.url);
    const key = url.pathname.slice(1);

    if (!authorizeRequest(request, env)) {
      return new Response("Forbidden", { status: 403 });
    }

    console.log(`${request.method} object ${key}: ${request.url}`);

    if (request.method === "GET" || request.method === "HEAD") {
      if (key === "") {
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
        const object = await env.R2_STORE.get(key, {
          range,
          onlyIf: request.headers,
        });

        if (object === null) {
          return objectNotFound(key);
        }

        const headers = new Headers();
        object.writeHttpMetadata(headers);
        headers.set("etag", object.httpEtag);

        const status = object.body ? (range ? 206 : 200) : 304;
        return new Response(object.body, {
          headers,
          status,
        });
      }

      const object = await env.R2_STORE.head(key);

      if (object === null) {
        return objectNotFound(key);
      }

      const headers = new Headers();
      object.writeHttpMetadata(headers);
      headers.set("etag", object.httpEtag);
      return new Response(null, {
        headers,
      });
    }

    if (request.method === "PUT" || request.method == "POST") {
      const object = await env.R2_STORE.put(key, request.body, {
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

    return new Response(`Unsupported method`, {
      status: 400,
    });
  },
};
