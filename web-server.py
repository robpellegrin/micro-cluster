import http.server
import socketserver
import subprocess
import os
from pathlib import Path

PORT = 2146
BASH_SCRIPT = './cluster-stats.bash'
OUTPUT_FILE = 'output.txt'


class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        try:
            result = subprocess.run(
                [BASH_SCRIPT], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except subprocess.CalledProcessError as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(f"Script failed:\n{e.stderr.decode()}".encode())
            return

        output_path = Path(OUTPUT_FILE)

        if not output_path.exists():
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"Output file not found.")
            return

        try:
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.send_header("Content-Length", str(output_path.stat().st_size))
            self.end_headers()
            with open(output_path, 'rb') as f:
                self.wfile.write(f.read())
        finally:
            try:
                output_path.unlink()
            except Exception as e:
                print(f"Warning: Could not delete output file: {e}")


if __name__ == "__main__":
    with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
        print(f"Serving on port {PORT}")
        httpd.serve_forever()
