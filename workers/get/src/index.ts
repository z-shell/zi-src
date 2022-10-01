export default {
  async fetch(request: Request): Promise<Response> {
    const destinationURL =
      "https://raw.githubusercontent.com/z-shell/zi-src/main/lib/sh/install.sh";
    const statusCode = 301;

    return Response.redirect(destinationURL, statusCode);
  },
};
