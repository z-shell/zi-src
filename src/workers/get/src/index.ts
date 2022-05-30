const destinationURL =
  "https://raw.githubusercontent.com/z-shell/zi-src/main/lib/sh/install.sh";
const statusCode = 301;

async function handleRequest(request) {
  return Response.redirect(destinationURL, statusCode);
}

addEventListener("fetch", async (event) => {
  event.respondWith(handleRequest(event.request));
});
