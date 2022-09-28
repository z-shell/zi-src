addEventListener("fetch", async (event) => {
  const request = event.request;
  try {
    return event.respondWith(handleRequest(request));
  } catch (e) {
    return event.respondWith(new Response(`Error thrown ${e.message}`));
  }
});

async function handleRequest(request) {
  const destinationURL =
    "https://raw.githubusercontent.com/z-shell/zi-src/main/lib/zsh/init.zsh";
  const statusCode = 301;
  return Response.redirect(destinationURL, statusCode);
}
