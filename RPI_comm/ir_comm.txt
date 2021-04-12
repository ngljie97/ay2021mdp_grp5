#IR - WIFI Connection Script

from config import *

import socket
import threading
import time

class IRWifi(object):
    
    #Initialise Object
    def __init__(self):
        self.tcp_ip = wifi_ip_address
        self.port = wifi_port_ir
        self.connection = None
        self.address = None
        self.client_soc = None
        self.ir_is_connected = False
        
    #Start and Create TCP/IP Socket
    def connect_ir(self):
        try:
            self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.connection.bind((self.tcp_ip,self.port))
            self.connection.listen(1)
            print("Listening for ir Connection")
            self.client_soc, self.address = self.connection.accept()
            print("Connection successful. Address of Device: ", self.address)
            self.ir_is_connected = True
            print("ir is Connected: %s" % self.ir_is_connected)
        
        except Exception as e:
            print("Connection Error Encountered. Error: %s" % str(e))
            
    #Close ir Connection
    def close_all(self):
        self.connection.close() #Close Server Connection
        self.client_soc.close() #Close Client Connection
    
    #Disconnect and Close socket
    def disconnect_ir(self):
        try:
            self.close_all()
            self.ir_is_connected = False
        
        except Exception as e:
            print("Error Occured: " % str(e))
            self.reconnect_ir()
            
    #Reconnect ir
    def reconnect_ir(self):
        self.disconnect_ir()
        self.connect_ir()
        
    #ir Connectivity Status
    def is_connected(self):
        return self.ir_is_connected
    
    #Write to ir
    def write_ir(self, ir_message):
        ir_message = ir_message + "\r" #Parse RAW Message
        try:
            self.client_soc.sendto(ir_message.encode("UTF-8"), self.address)
            
        except Exception as e:
            print("Write Error... %s" % str(e))
            self.reconnect_ir()
            
    #Read from ir
    def read_ir(self):
        try:
            ir_message_read = self.client_soc.recv(2048)
            return ir_message_read.decode("UTF-8")
        
        except Exception as e:
            print("Read Error... %s" % str(e))
            self.reconnect_ir()
