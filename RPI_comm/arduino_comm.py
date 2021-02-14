#Arduino Serial Communication Script

from config import *

import time
import serial
import threading

class Arduinoser(object):
    
    #Arduino Initialisation
    def __init__(self):
        self.port = ser_port
        self.baud_rate = baudrate
        self.ser_connection = None
        self.arduino_is_connected = False
    
    #Start and Create Serial Port Connection
    def connect_ser(self):
        try:
            self.ser_connection = serial.Serial(self.port, self.baud_rate)
            self.arduino_is_connected = True
            print("Serial Link Connection to Arduino is Established")
            
        except Exception as e:
            print("Failed to Connect to Arduino Serial Link. Error: %s" %str(e))
            
    #Disconnect and Close Serial Port Cnnection
    def disconnect_ser(self):
        try:
            self.ser_connection.close()
            self.arduino_is_connected = False
            print("Serial Link Successfully Closed")
        
        except Exception as e:
            print("Failed to close Serial Link. Error: %s" %str(e))
            
    #Reconnect Arduino Connections
    def reconnect_ser(self):
        self.disconnect_ser()
        time.sleep(2)
        self.connect_ser()
        
    #Return Arduino Connectivity Status
    def is_connected(self):
        return self.arduino_is_connected
    
    #Write to Arduino via Serial Link
    def write_ser(self, ser_message):
        try:
            self.ser_connection.write(str(ser_message).encode("UTF-8"))
        except Exception as e:
            print("Error: Cannot Write to Arduino")
            self.reconnect_ser()
            
    #Read from Arduino via Serial Link
    def read_ser(self):
        try:
            ser_message_read = self.ser_connection.readline()
            return ser_message_read.decode("UTF-8")
        
        except AttributeError:
            print("Error: Cannot Write to Arduino")
            self.reconnect_ser()

