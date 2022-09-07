var http = require('http');

function getRandomInt(max) {
  return Math.floor(Math.random() * max);
}

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(getRandomInt(20).toString());
}).listen(8080);