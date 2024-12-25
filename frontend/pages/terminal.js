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
