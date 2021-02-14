import multiprocessing as mp
import threading
import time
import json
from datetime import datetime
from picamera import PiCamera
from picamera.array import PiRGBArray
import cv2 as cv
import numpy as np

import bt_comm as bt
import pc_comm as pc
import arduino_comm as ser

class Main(threading.Thread):
    
    #Initialise threads
    def __init__(self):
        threading.Thread.__init__(self)

        #Initialise component scripts - BT, PC, WIFI
        self.bt_thread = bt.AndroidBT()
        self.pc_thread = pc.PCWifi()
        self.ser_thread = ser.Arduinoser()
        self.xy_cord = "11"
        self.sdata = "0"
        self.instr = "Z"
        self.counter = 0

        #Initialise PICAMERA
        self.camera = PiCamera()
        self.camera.resolution = (1280,720)
        self.camera.start_recording('exploration.h264')
        print(str(datetime.now()) + " Camera is Recording")
        
        #Iniitalise queue for messages to send
        self.bt_queue = mp.Queue(maxsize=10)
        self.pc_queue = mp.Queue(maxsize=10)
        self.ser_queue = mp.Queue(maxsize=10)
        
        #Initialise connections for BT, PC, WIFI
        self.bt_thread.connect_bt()
        self.pc_thread.connect_pc()
        self.ser_thread.connect_ser()

    #Disconnect all sockets from RPI
    def disconnect_threads(self):
        self.bt_thread.disconnect_bt()
        self.pc_thread.disconnect_pc()
        self.ser_thread.disconnect_ser()
        self.camera.stop_recording()
        self.camera.close()
        print("Disconnecting all connections...\n Closing all threads...")
        
    #Reconnect all sockets to RPI
    def reconnect_all(self):
        self.bt_thread.reconnect_bt()
        self.pc_thread.reconnect_pc()
        self.ser_thread.reconnect_ser()
        
    #Maintain Main calling program... ctrl + c closes the program
    def maintain_process(self):
        while True:
            time.sleep(0.1)
            
    def split_cmd(self, message):
        split_arr = message.split(':')
        return split_arr
    
    def split_json(self, message):
        json_arr = message.split(',')
        return json_arr

    def split_multitype(self, message):
        multimsg_array = message.split("\n")
        return multimsg_array

    def takepic(self):
        try:
            print("Capturing Image Coordinate %s ...." % self.xy_cord)
            self.camera.capture('/home/pi/mdp16-rpi/IR/captured_data/%s.jpg' % self.xy_cord, use_video_port=True)
            print("Image Capture Complete! Next Move..")
        except Exception as e:
            print("Error taking picture... %s" % str(e))
            self.takepic()

    #########                       PC                 #########
    
    def write_to_pc(self, message):
        self.pc_queue.put(message)
        return True
    
    def write_thread_pc(self):
        while True:
            pc_message = self.pc_queue.get()
            if self.pc_thread.is_connected() and pc_message:
                self.pc_thread.write_pc(pc_message)

    def read_from_pc(self):
        while True:
            pc_message_received = self.pc_thread.read_pc()
            if self.pc_thread.is_connected() and pc_message_received:
                n_split = self.split_multitype(pc_message_received)

                for msg in n_split:
                    instr_type = self.split_cmd(msg)

                    #PC to N7
                    if (instr_type[0].strip() == 'ROBOT'):
                        print(str(datetime.now()) + " PC - N7: %s" % msg)
                        pc_message_sent = self.write_to_bt(msg)

                        replaced_msg = msg.replace('\"', '')
                        replaced_msg = replaced_msg.replace('{', '')
                        replaced_msg = replaced_msg.replace('}', '')
                        replaced_msg = replaced_msg.replace(',', ':')
                        replaced_msg = replaced_msg.replace('(', '')
                        replaced_msg = replaced_msg.replace(')', '')
                        msg_arr = replaced_msg.split(':')
                        
                        x_cord = str(msg_arr[6])
                        y_cord = str(msg_arr[7])
                        self.xy_cord = "%s%s" % (str(x_cord), str(y_cord))
                        heading = str(msg_arr[12])

#                        time.sleep(0.1)

                        if (self.sdata == '1') | (self.instr == 'L') | (self.instr == 'R'):
                            if (x_cord.strip() == '1' and heading.strip() == 'S') | (x_cord.strip() == '13' and heading.strip() == 'N') | (y_cord.strip() == '1' and heading.strip() == 'E') | (y_cord.strip() == '18' and heading.strip() == 'W'):
                                print("Camera Facing Wall")
                                self.counter = 0

                            elif (self.instr == 'L') | (self.instr == 'R'):
                                self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                                print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                                self.takepic()
                                self.counter = 2
                            else:
                                if (heading.strip() == 'S'):
#                                self.x_cord = int(self.x_cord) - 1
                                    self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                                    print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                                    self.takepic()
                                    self.counter = 2

                                elif (heading.strip() == 'N'):
#                                self.x_cord = int(self.x_cord) + 1
                                    self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                                    print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                                    self.takepic()
                                    self.counter = 2

                                elif (heading.strip() == 'E'):
#                                self.y_cord = int(self.y_cord) - 1
                                    self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                                    print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                                    self.takepic()
                                    self.counter = 2

                                elif (heading.strip() == 'W'):
#                                self.y_cord = int(self.y_cord) + 1
                                    self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                                    print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                                    self.takepic()
                                    self.counter = 2

                        elif (self.counter > 0):
                            self.xy_cord = "%s%s" % (str(x_cord.strip()), str(y_cord.strip()))
                            print(str(datetime.now()) + " Object Cord: %s" % self.xy_cord)
                            self.takepic()
                            self.counter = self.counter - 1
                        else:
                            pass
                    #PC to Dora
                    elif (instr_type[0] == 'BOT_START') | (instr_type[0] == 'INSTR'):
                        print(str(datetime.now()) + " PC - Dora: %s" % instr_type[1])
                        time.sleep(0.1)
                        pc_message_sent = self.write_to_ser(instr_type[1])

                        if (instr_type[0] == 'INSTR'):
                            self.instr = str(instr_type[1])

                    elif (instr_type[0].strip() == 'EX_DONE'):
                        self.camera.stop_recording()
                        self.camera.close()
                    #Incorrect Device
                    else:
                        pass

    #########                       N7                 #########
                    
    def write_to_bt(self, bt_message):
        self.bt_queue.put(bt_message)
        return True
    
    def write_thread_bt(self):
        while True:
            bt_message = self.bt_queue.get()
            bt_message = bt_message.encode("UTF-8")
            if self.bt_thread.is_connected() and bt_message:
                self.bt_thread.write_bt(bt_message)
                
    def read_from_bt(self):
        while True:
            bt_message_received = self.bt_thread.read_bt()
            if self.bt_thread.is_connected() and bt_message_received:
                instr_type = self.split_cmd(bt_message_received)
                
                #N7 to PC
                if (instr_type[0] == 'EX_START') | (instr_type[0] == 'WP') | (instr_type[0] == 'FP_START') :
                    print(str(datetime.now()) + " N7 - PC: %s" % bt_message_received)
                    bt_message_sent = self.write_to_pc(bt_message_received)

                    if (instr_type[0] == 'FP_START') :
                        bt_message_sent = self.write_to_ser("F")

                #N7 to Dora
                elif (instr_type[0] == 'A') | (instr_type[0] == 'L') | (instr_type[0] == 'R'):
                    print(str(datetime.now()) + " N7 - Dora: %s" % bt_message_received)
                    bt_message_sent = self.write_to_ser(bt_message_received)
                else:
                    pass

    #########                       Arduino                 #########
                        
    def write_to_ser(self, ser_message):
        self.ser_queue.put(ser_message)
        return True
    
    def write_thread_ser(self):
        while True:
            ser_message = self.ser_queue.get()
            if self.ser_thread.is_connected() and ser_message:
                self.ser_thread.write_ser(ser_message)

    def read_from_ser(self):
        while True:
            ser_message_received = self.ser_thread.read_ser()
            if self.ser_thread.is_connected() and ser_message_received:
                instr_type = self.split_cmd(ser_message_received)
                
                #Dora to PC
                if (instr_type[0] == 'SDATA') | (instr_type[0].strip() == 'CALIDONE'):
                    print(str(datetime.now()) + " DORA - PC: %s" % ser_message_received)
                    ser_message_sent = self.write_to_pc(ser_message_received.strip())
                    if (instr_type[0] == 'SDATA'):
                        self.sdata = str(instr_type[5].strip())
                else:
                    pass

    #Initialise threads from read/write of devices
    def initiate_threads(self):
        
        #Initialise PC WIFI threads
        read_threads_pc = threading.Thread(target=self.read_from_pc, name="pc_read_thread")
        write_threads_pc = threading.Thread(target=self.write_thread_pc, name="pc_write_thread")
        
        #Initialise N7 BT threads
        read_threads_bt = threading.Thread(target=self.read_from_bt, name="bt_read_thread")
        write_threads_bt = threading.Thread(target=self.write_thread_bt, name="bt_write_thread")
        
        #Initialise Arduino Serial threads
        read_threads_ser = threading.Thread(target=self.read_from_ser, name="ser_read_thread")
        write_threads_ser = threading.Thread(target=self.write_thread_ser, name="ser_write_thread")

        # Setting threads as Daemons
        read_threads_pc.daemon = True
        write_threads_pc.daemon = True

        read_threads_bt.daemon = True
        write_threads_bt.daemon = True

        read_threads_ser.daemon = True
        write_threads_ser.daemon = True
        
        read_threads_pc.start()
        write_threads_pc.start()
        
        read_threads_bt.start()
        write_threads_bt.start()
        
        read_threads_ser.start()
        write_threads_ser.start()
        
if __name__ == "__main__":
    print("\nInitializing Program... Please Wait...")
    init = Main()
    init.initiate_threads()
    init.maintain_process()
    print("Force Close Initiated... Closing Program...")
    init.disconnect_threads()
                        

