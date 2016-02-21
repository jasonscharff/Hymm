var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(1997);

app.get('/', function (req, res) {
  res.json({result:'success'});
});

io.on('connection', function (socket) {
  socket.emit('news', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});

console.log('running');