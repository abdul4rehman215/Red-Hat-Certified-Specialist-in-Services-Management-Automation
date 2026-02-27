#!/usr/bin/env python3
import http.server
import socketserver
import os
import signal
import sys
from datetime import datetime

PORT = 8080
DIRECTORY = "/tmp/webserver"

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        if self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            response = f"""
            <html>
            <body>
            <h1>Custom Web Server Status</h1>
            <p>Server is running on port {PORT}</p>
            <p>Current time: {datetime.now()}</p>
            <p>PID: {os.getpid()}</p>
            </body>
            </html>
            """
            self.wfile.write(response.encode())
        else:
            super().do_GET()

def signal_handler(signum, frame):
    print(f"Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

def main():
    # Create web directory if it doesn't exist
    os.makedirs(DIRECTORY, exist_ok=True)

    # Create a simple index.html file
    with open(f"{DIRECTORY}/index.html", "w") as f:
        f.write("""
        <html>
        <body>
        <h1>Welcome to Custom Web Server</h1>
        <p>This is a custom systemd service!</p>
        <p><a href="/status">Check Status</a></p>
        </body>
        </html>
        """)

    # Set up signal handlers for graceful shutdown
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)

    print(f"Starting web server on port {PORT}")
    print(f"Serving directory: {DIRECTORY}")

    with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("Server interrupted, shutting down...")
        finally:
            httpd.shutdown()

if __name__ == "__main__":
    main()
