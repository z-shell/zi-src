const destinationURL = "https://github.zshell.dev/zi-src/zsh/init.zsh";
const statusCode = 301;

async function handleRequest(request) {
  return Response.redirect(destinationURL, statusCode);
}

addEventListener("fetch", async (event) => {
  event.respondWith(handleRequest(event.request));
});
