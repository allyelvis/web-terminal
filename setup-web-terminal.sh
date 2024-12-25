#!/bin/bash

# Define project names
PROJECT_NAME="web-terminal"
BACKEND_NAME="backend"
FRONTEND_NAME="frontend"

echo "🚀 Starting setup for Web Terminal Project..."

# 1. Create Project Structure
echo "📂 Creating project structure..."
mkdir $PROJECT_NAME && cd $PROJECT_NAME
mkdir $BACKEND_NAME && mkdir $FRONTEND_NAME

# 2. Initialize Frontend (Next.js)
echo "🌐 Setting up Next.js frontend..."
cd $FRONTEND_NAME
npx create-next-app . --use-npm
npm install xterm axios socket.io-client

# Add xterm terminal to Next.js
cat > pages/terminal.js <<EOL
import { useEffect, useRef } from 'react';
import { Terminal } from 'xterm';
import 'xterm/css/xterm.css';
import io from 'socket.io-client';

export default function WebTerminal() {
  const termRef = useRef(null);
  let socket;

  useEffect(() => {
    const term = new Terminal();
    term.open(termRef.current);

    socket = io('https://your-backend-url');

    term.onData((data) => {
      socket.emit('command', data);
    });

    socket.on('output', (data) => {
      term.write(data);
    });

    return () => socket.disconnect();
  }, []);

  return <div ref={termRef} style={{ height: '100vh' }} />;
}
EOL

cd ..

# 3. Initialize Backend (Node.js + Express)
echo "🛠️  Setting up Node.js backend..."
cd $BACKEND_NAME
npm init -y
npm install express socket.io docker-cli-js

cat > server.js <<EOL
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
    docker.command(\`docker run --rm cli-container \${cmd}\`).then((data) => {
      socket.emit('output', data.raw);
    });
  });
});

server.listen(5000, () => {
  console.log('Server running on port 5000');
});
EOL

cd ..

# 4. Create Docker Container for CLI
echo "🐳 Creating Docker container for CLI tools..."
cat > Dockerfile <<EOL
FROM node:16
RUN npm install -g @vercel/cli firebase-tools gh
CMD ["/bin/bash"]
EOL

docker build -t cli-container .

# 5. Firebase Functions Setup
echo "🔥 Setting up Firebase functions..."
firebase init functions

# Replace functions/index.js with backend logic
cat > functions/index.js <<EOL
const functions = require('firebase-functions');
const express = require('express');
const app = express();
const { exec } = require('child_process');

app.post('/cli', (req, res) => {
  const command = req.body.command;

  exec(command, (err, stdout, stderr) => {
    if (err) {
      res.send({ error: stderr });
      return;
    }
    res.send({ output: stdout });
  });
});

exports.api = functions.https.onRequest(app);
EOL

# 6. Deploy Backend to Firebase
echo "🚀 Deploying backend to Firebase..."
firebase deploy --only functions

# 7. Deploy Frontend to Vercel
echo "🌐 Deploying frontend to Vercel..."
cd $FRONTEND_NAME
vercel deploy --prod

echo "✅ Setup complete. Access your web terminal at the Vercel URL."
