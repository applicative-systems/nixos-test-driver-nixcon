import socket
import sys

HOST = ""

try:
    PORT = int(sys.argv[1])
except:
    print("Please provide a port number on the command line")
    sys.exit(1)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()

    while True:
        conn, addr = s.accept()
        with conn:
            while True:
                data = conn.recv(1024)
                if not data:
                    break
                conn.sendall(data)
