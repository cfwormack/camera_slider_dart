import threading
from flask import Flask
from flask_socketio import SocketIO, emit
import arduino_serial as arduino


app = Flask(__name__)
# cors_allowed_origins="*" is vital for development
socketio = SocketIO(app, cors_allowed_origins="*")
serial_thread=arduino.SerialThread(port='COM3', baud=9600)
#
@socketio.on('connect')
def handle_connect():
    serial_thread.start()
    print("Client connected!")

@socketio.on('disconnect')
def handle_disconnect():
    print("Client disconnected!")
    serial_thread.stop()
    exit(0)
   
    

@socketio.on('slider_move')
def handle_slider_move(data):
    # This captures the value in real-time
    value = data.get('value')
    #print(f"Live Slider Value: {value}")
    # Send the value to Arduino via serial
    
    serial_thread.send(value)
    # delay to ensure Arduino processes the command
    threading.Event().wait(5)
    # Optional: Send something back to the frontend
    emit('response', {'message': f'Server saw {value}'})




if __name__ == '__main__':
    # start the flask server with socketio
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
    
  
    
    
    