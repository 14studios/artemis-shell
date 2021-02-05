#!/usr/bin/env node
const os = require("os");
const args = process.argv.slice(2);

require("http").get({ host: "motd.artemis.org.uk", port: 80, path: "/version.html"}, function(res) {
  console.log("Got response: " + res.statusCode);

  res.on("data", function(chunk) {
      os.ctlversion = chunk;
  });
}).on('error', function(e) {
  console.log("Got error: " + e.message);
});


if (args.includes("-v") || args.includes("--version")) {
    console.log(`artemisctl v${os.ctlversion}`);
};