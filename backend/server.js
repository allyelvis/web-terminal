const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const { Docker } = require('docker-cli-js');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const docker = new Docker();

io.on('connection', (socket) => {
  socket.on('command', (cmd) => {
    docker.command(`docker run --rm cli-container ${cmd}`).then((data) => {
      socket.emit('output', data.raw);
    });
  });
});

server.listen(5000, () => {
  console.log('Server running on port 5000');
});
