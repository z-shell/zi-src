const destinationURL = "https://r2.zshell.dev/src/sh/install.sh";
const statusCode = 301;

async function handleRequest(request) {
  return Response.redirect(destinationURL, statusCode);
}

addEventListener("fetch", async (event) => {
  event.respondWith(handleRequest(event.request));
});

/**
export default {
  fetch(request) {
    const base = "https://r2.zshell.dev/src/sh/install.sh";
    const statusCode = 301;

    const destination = new URL(request.url, base);
    return Response.redirect(destination.toString(), statusCode);
  },
};
*/
