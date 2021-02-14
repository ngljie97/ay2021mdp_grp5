import multiprocessing as mp
import threading
import time
from datetime import datetime

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
        
        #Inisitalise queue for messages to send
        self.bt_queue = mp.Queue(maxsize=10)
        self.pc_queue = mp.Queue(maxsize=10)
        self.ser_queue = mp.Queue(maxsize=10)
        
        #Initialise connections for BT, PC, WIFI
        self.bt_thread.connect_bt()
        self.pc_thread.connect_pc()
        self.ser_thread.connect_ser()
##        time.sleep(1)
        
    #Disconnect all sockets from RPI
    def disconnect_threads(self):
        self.bt_thread.disconnect_bt()
        self.pc_thread.disconnect_pc()
        self.ser_thread.disconnect_ser()
        print("Disconnecting all connections...\n Closing all threads...")
        
    #Reconnect all sockets to RPI
    def reconnect_all(self):
        self.bt_thread.reconnect_bt()
        self.pc_thread.reconnect_pc()
        self.ser_thread.reconnect_ser()
        
    #Maintain Main calling program... ctrl + c closes the program
    def maintain_process(self):
        while True:
##            time.sleep(1)
            time.sleep(0.1)
            
    def split_cmd(self, message):
        split_arr = message.split(':')
        return split_arr

    def split_multitype(self, message):
        multimsg_array = message.split("\n")
        return multimsg_array
    
    #########                       PC                 #########
    
    def write_to_pc(self, message):
        self.pc_queue.put(message)
        return True
    
    def write_thread_pc(self):
        while True:
            pc_message = self.pc_queue.get()
            if self.pc_thread.is_connected() and pc_message:
                self.pc_thread.write_pc(pc_message)
               # print("%s, send to PC " % pc_message)
                
    def read_from_pc(self):
        while True:
            pc_message_received = self.pc_thread.read_pc()
            if self.pc_thread.is_connected() and pc_message_received:
#                print("RAW Message from PC: %s" % str(pc_message_received))
                n_split = self.split_multitype(pc_message_received)

                for msg in n_split:
                    instr_type = self.split_cmd(msg)
#                    print("Message from PC: %s" % str(instr_type))

                    #PC to N7
                    if (instr_type[0] == 'MAP') | (instr_type[0] == 'BOT_POS') | (instr_type[0].strip() == 'ROBOT'):
                        print(str(datetime.now()) + " Sending to N7: %s" % msg)
                        pc_message_sent = self.write_to_bt(msg)

                    #PC to Dora
                    elif (instr_type[0] == 'BOT_START') | (instr_type[0] == 'INSTR'):
                        print(str(datetime.now()) + " Sending to Dora: %s" % instr_type[1])
                        pc_message_sent = self.write_to_ser(instr_type[1])
                    #Incorrect Device
                    else:
                        pass
#                        print(str(datetime.now()) + " Incorrect WiFi Instruction Type Selected: %s" % pc_message_received)
                    

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
                #print("%s, Sending to N7\n" % bt_message)
                
    def read_from_bt(self):
        while True:
            bt_message_received = self.bt_thread.read_bt()
            if self.bt_thread.is_connected() and bt_message_received:
                instr_type = self.split_cmd(bt_message_received)
                
                #N7 to PC
                if (instr_type[0] == 'EX_START') | (instr_type[0] == 'WP') | (instr_type[0] == 'FP_START') :
                    print(str(datetime.now()) + " Sending to PC: %s" % bt_message_received)
                    bt_message_sent = self.write_to_pc(bt_message_received)

                    if instr_type[0] == 'FP_START':
                        bt_message_sent = self.write_to_ser('F')

                #N7 to Dora
                elif (instr_type[0] == 'A') | (instr_type[0] == 'L') | (instr_type[0] == 'R') | (instr_type[0] == 'C') | (instr_type[0] == 'O') | (instr_type[0] == 'S'):
                    print(str(datetime.now()) + " Message from N7: %s" % bt_message_received)
                    bt_message_sent = self.write_to_ser(bt_message_received)

                elif (instr_type[0] == 'PC') :
                    print("PC Connection Status: %s" % str(self.pc_thread.is_connected()))
                elif (instr_type[0] == 'DORA') :
                    print("DORA Connection Status: %s" % str(self.ser_thread.is_connected()))
                else:
                    pass
#                    print(str(datetime.now()) + " Incorrect BT Instruction Type Selected: %s" % bt_message_received)
                        
    #########                       Arduino                 #########
                        
    def write_to_ser(self, ser_message):
        self.ser_queue.put(ser_message)
        return True
    
    def write_thread_ser(self):
        while True:
            ser_message = self.ser_queue.get()
            if self.ser_thread.is_connected() and ser_message:
                self.ser_thread.write_ser(ser_message)
                #print("%s, Sending to Dora" % ser_message)
                
    def read_from_ser(self):
        while True:
            ser_message_received = self.ser_thread.read_ser()
            if self.ser_thread.is_connected() and ser_message_received:
                instr_type = self.split_cmd(ser_message_received)
                
                #Dora to PC
                if (instr_type[0] == 'SDATA') | (instr_type[0].strip() == 'CALIDONE'):
                    print(str(datetime.now()) + " Sending to PC: %s" % ser_message_received)
                    ser_message_sent = self.write_to_pc(ser_message_received.strip())

                else:
                    pass
#                    print(str(datetime.now()) + " Incorrect SER Instruction Type Selected: %s" % ser_message_received)
    
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

        #Setting threads as Daemons
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
                        
