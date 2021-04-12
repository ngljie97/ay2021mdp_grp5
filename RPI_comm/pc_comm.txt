#PC - WIFI Connection Script

from config import *

import socket
import threading
import time

class PCWifi(object):
    
    #Initialise Object
    def __init__(self):
        self.tcp_ip = wifi_ip_address
        self.port = wifi_port
        self.connection = None
        self.address = None
        self.client_soc = None
        self.pc_is_connected = False
        
    #Start and Create TCP/IP Socket
    def connect_pc(self):
        try:
            self.connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.connection.bind((self.tcp_ip,self.port))
            self.connection.listen(1)
            print("Listening for PC Connection")
            self.client_soc, self.address = self.connection.accept()
            print("Connection successful. Address of Device: ", self.address)
            self.pc_is_connected = True
            print("PC is Connected: %s" % self.pc_is_connected)
        
        except Exception as e:
            print("Connection Error Encountered. Error: %s" % str(e))
            
    #Close PC Connection
    def close_all(self):
        self.connection.close() #Close Server Connection
        self.client_soc.close() #Close Client Connection
    
    #Disconnect and Close socket
    def disconnect_pc(self):
        try:
            self.close_all()
            self.pc_is_connected = False
        
        except Exception as e:
            print("Error Occured: " % str(e))
            self.reconnect_pc()
            
    #Reconnect PC
    def reconnect_pc(self):
        self.disconnect_pc()
        self.connect_pc()
        
    #PC Connectivity Status
    def is_connected(self):
        return self.pc_is_connected
    
    #Write to PC
    def write_pc(self, pc_message):
        pc_message = pc_message + "\r" #Parse RAW Message
        try:
            self.client_soc.sendto(pc_message.encode("UTF-8"), self.address)
            
        except Exception as e:
            print("Write Error... %s" % str(e))
            self.reconnect_pc()
            
    #Read from PC
    def read_pc(self):
        try:
            pc_message_read = self.client_soc.recv(2048)
            return pc_message_read.decode("UTF-8")
        
        except Exception as e:
            print("Read Error... %s" % str(e))
            self.reconnect_pc()
