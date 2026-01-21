import threading

import serial
import serial.tools.list_ports

class SerialThread(threading.Thread):
    def __init__(self, port, baud):
        super().__init__(daemon=True)
        self.port = port
        self.baud = baud
        self.running = True
        self.ser = None

    def run(self):
        try:
            self.ser = serial.Serial(self.port, self.baud, timeout=1)
            print("Serial port opened")
            while self.running:
                if self.ser.in_waiting > 0:
                    line = self.ser.readline().decode().strip()
                    if line:
                        print("[RX]", line)
        except Exception as e:
            print("Serial error:", e)

    def send(self, msg: str):
        if self.ser and self.ser.is_open:
            self.ser.write((msg + "\n").encode())
            print("[TX]", msg)

    def stop(self):
        self.running = False
        if self.ser and self.ser.is_open:
            self.ser.close()
