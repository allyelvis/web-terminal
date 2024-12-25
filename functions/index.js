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
