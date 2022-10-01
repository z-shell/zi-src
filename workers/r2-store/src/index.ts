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
    `<!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <title></title>
        <script
          src="https://cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.3/modernizr.min.js"
          integrity="sha512-3n19xznO0ubPpSwYCRRBgHh63DrV+bdZfHK52b1esvId4GsfwStQNPJFjeQos2h3JwCmZl0/LgLxSKMAI55hgw=="
          crossorigin="anonymous"
          referrerpolicy="no-referrer"
          type="text/javascript"
        ></script>
        <link
          rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/meyer-reset/2.0/reset.min.css"
          integrity="sha512-NmLkDIU1C/C88wi324HBc+S2kLhi08PN5GDeUVVVC/BVt/9Izdsc9SVeVfA1UZbY3sHUlDSyRXhCzHfr6hmPPw=="
          crossorigin="anonymous"
          referrerpolicy="no-referrer"
        />
        <style>
          body {
            background-color: #2f3242;
          }
          svg {
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -250px;
            margin-left: -400px;
          }
          .message-box {
            height: 200px;
            width: 380px;
            position: absolute;
            top: 50%;
            left: 50%;
            margin-top: -100px;
            margin-left: 50px;
            color: #fff;
            font-family: Roboto;
            font-weight: 300;
          }
          .message-box h1 {
            font-size: 60px;
            line-height: 46px;
            margin-bottom: 40px;
          }
          .buttons-con .action-link-wrap {
            margin-top: 40px;
          }
          .buttons-con .action-link-wrap a {
            background: #68c950;
            padding: 8px 25px;
            border-radius: 4px;
            color: #fff;
            font-weight: bold;
            font-size: 14px;
            transition: all 0.3s linear;
            cursor: pointer;
            text-decoration: none;
            margin-right: 10px;
          }
          .buttons-con .action-link-wrap a:hover {
            background: #5a5c6c;
            color: #fff;
          }

          #Polygon-1,
          #Polygon-2,
          #Polygon-3,
          #Polygon-4,
          #Polygon-4,
          #Polygon-5 {
            -webkit-animation: float 1s infinite ease-in-out alternate;
            animation: float 1s infinite ease-in-out alternate;
          }
          #Polygon-2 {
            -webkit-animation-delay: 0.2s;
            animation-delay: 0.2s;
          }
          #Polygon-3 {
            -webkit-animation-delay: 0.4s;
            animation-delay: 0.4s;
          }
          #Polygon-4 {
            -webkit-animation-delay: 0.6s;
            animation-delay: 0.6s;
          }
          #Polygon-5 {
            -webkit-animation-delay: 0.8s;
            animation-delay: 0.8s;
          }

          @-webkit-keyframes float {
            100% {
              transform: translateY(20px);
            }
          }

          @keyframes float {
            100% {
              transform: translateY(20px);
            }
          }
          @media (max-width: 450px) {
            svg {
              position: absolute;
              top: 50%;
              left: 50%;
              margin-top: -250px;
              margin-left: -190px;
            }
            .message-box {
              top: 50%;
              left: 50%;
              margin-top: -100px;
              margin-left: -190px;
              text-align: center;
            }
          }
        </style>
      </head>
      <body>
        <!-- partial:index.partial.html -->
        <svg
          width="380px"
          height="500px"
          viewBox="0 0 837 1045"
          version="1.1"
          xmlns="http://www.w3.org/2000/svg"
          xmlns:xlink="http://www.w3.org/1999/xlink"
          xmlns:sketch="http://www.bohemiancoding.com/sketch/ns"
        >
          <g
            id="Page-1"
            stroke="none"
            stroke-width="1"
            fill="none"
            fill-rule="evenodd"
            sketch:type="MSPage"
          >
            <path
              d="M353,9 L626.664028,170 L626.664028,487 L353,642 L79.3359724,487 L79.3359724,170 L353,9 Z"
              id="Polygon-1"
              stroke="#007FB2"
              stroke-width="6"
              sketch:type="MSShapeGroup"
            ></path>
            <path
              d="M78.5,529 L147,569.186414 L147,648.311216 L78.5,687 L10,648.311216 L10,569.186414 L78.5,529 Z"
              id="Polygon-2"
              stroke="#EF4A5B"
              stroke-width="6"
              sketch:type="MSShapeGroup"
            ></path>
            <path
              d="M773,186 L827,217.538705 L827,279.636651 L773,310 L719,279.636651 L719,217.538705 L773,186 Z"
              id="Polygon-3"
              stroke="#795D9C"
              stroke-width="6"
              sketch:type="MSShapeGroup"
            ></path>
            <path
              d="M639,529 L773,607.846761 L773,763.091627 L639,839 L505,763.091627 L505,607.846761 L639,529 Z"
              id="Polygon-4"
              stroke="#F2773F"
              stroke-width="6"
              sketch:type="MSShapeGroup"
            ></path>
            <path
              d="M281,801 L383,861.025276 L383,979.21169 L281,1037 L179,979.21169 L179,861.025276 L281,801 Z"
              id="Polygon-5"
              stroke="#36B455"
              stroke-width="6"
              sketch:type="MSShapeGroup"
            ></path>
          </g>
        </svg>
        <div class="message-box">
          <h1>404</h1>
            <br />
              <h2><b>UH OH!</b> You are lost.</h2>
              <br />
                <p>
                  The page you are looking for does not exist. How you got here is a
                  mystery. But you can click the button below to go back to the
                  homepage.
                </p>
          <div class="buttons-con">
            <div class="action-link-wrap">
              <a
                onclick="history.back(-1)"
                class="link-button link-back-button"
                >Go Back</a
              >
              <!-- <a href="https://github.com/ss-o" class="link-button">Go to Home Page</a> -->
            </div>
          </div>
        </div>
        <!-- partial -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.1/jquery.min.js" integrity="sha512-aVKKRRi/Q/YV+4mjoKBsE4x3H+BkegoM/em46NNlCqNTmUYADjBbeNefNxYV7giUp0VxICtqdrbqU7iVaeZNXA==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
      </body>
    </html>`,
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
    case "POST":
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
