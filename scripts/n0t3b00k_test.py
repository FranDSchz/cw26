import socket
import time

def recv_until(sock, suffix):
    data = b""
    while not data.endswith(suffix):
        chunk = sock.recv(1)
        if not chunk:
            break
        data += chunk
    return data

def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect(("localhost", 2323))
    except Exception as e:
        print(f"Failed to connect: {e}")
        return

    print("--- Connected! ---")
    print(recv_until(s, b"> ").decode(), end="")

    commands = [
        "reg testuser testpass",
        "log testuser testpass",
        "set hello, this is a test note",
        "list",
        "dump",
        "exit"
    ]

    for cmd in commands:
        print(cmd)
        s.sendall(cmd.encode() + b"\n")
        if cmd == "exit":
            print(s.recv(1024).decode())
            break
        print(recv_until(s, b"> ").decode(), end="")

    s.close()

if __name__ == "__main__":
    main()
