export default {
  async fetch(request: Request) {
    const HOMEPAGE_URL = "https://r2.zshell.dev/";
    const PROTECTED_TYPE = "img/";

    const response = await fetch(request);
    const referer = request.headers.get("Referer");
    const contentType = response.headers.get("Content-Type") || "";

    if (referer && contentType.startsWith(PROTECTED_TYPE)) {
      if (new URL(referer).hostname !== new URL(request.url).hostname) {
        return Response.redirect(HOMEPAGE_URL, 302);
      }
    }

    return response;
  },
};
