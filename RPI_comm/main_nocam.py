import multiprocessing as mp
import threading
import time
from datetime import datetime

import bt_comm as bt
import pc_comm as pc
import ir_comm as ir
import arduino_comm as ser

class Main(threading.Thread):
    
    #Initialise threads
    def __init__(self):
        threading.Thread.__init__(self)

        #Initialise component scripts - BT, PC, WIFI
        self.bt_thread = bt.AndroidBT()
        self.pc_thread = pc.PCWifi()
        self.ir_thread = ir.IRWifi()
        self.ser_thread = ser.Arduinoser()
        
        #Inisitalise queue for messages to send
        self.bt_queue = mp.Queue(maxsize=10)
        self.pc_queue = mp.Queue(maxsize=10)
        self.ir_queue = mp.Queue(maxsize=10)
        self.ser_queue = mp.Queue(maxsize=10)
        
        #Initialise connections for BT, PC, WIFI
        self.bt_thread.connect_bt()
        self.pc_thread.connect_pc()
        self.ir_thread.connect_ir()
        self.ser_thread.connect_ser()
##        time.sleep(1)
        
    #Disconnect all sockets from RPI
    def disconnect_threads(self):
        self.bt_thread.disconnect_bt()
        self.pc_thread.disconnect_pc()
        self.ir_thread.disconnect_ir()
        self.ser_thread.disconnect_ser()
        print("Disconnecting all connections...\n Closing all threads...")
        
    #Reconnect all sockets to RPI
    def reconnect_all(self):
        self.bt_thread.reconnect_bt()
        self.pc_thread.reconnect_pc()
        self.ir_thread.reconnect_ir()
        self.ser_thread.reconnect_ser()
        
    #Maintain Main calling program... ctrl + c closes the program
    def maintain_process(self):
        while True:
##            time.sleep(1)
            time.sleep(0.1)
            
    def split_cmd(self, message):
        split_arr = message.split('|')
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

                    #PC to Android
                    if 'A' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to N7: %s" % instr_type[1])
                        pc_message_sent = self.write_to_bt(instr_type[1])
                
                    #PC to Arduino
                    if 'R' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to Robot: %s" % instr_type[1])
                        pc_message_sent = self.write_to_ser(instr_type[1])
                    
                    #PC to IR
                    if 'I' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to IR: %s" % instr_type[1])
                        pc_message_sent = self.write_to_ir(instr_type[1])

                    #Incorrect Device
                    else:
                        pass
#                        print(str(datetime.now()) + " Incorrect WiFi Instruction Type Selected: %s" % pc_message_received)
                    

#########                       IR                 #########

    def write_to_ir(self, message):
        self.ir_queue.put(message)
        return True

    def write_thread_ir(self):
        while True:
            ir_message = self.ir_queue.get()
            if self.ir_thread.is_connected() and ir_message:
                self.ir_thread.write_ir(ir_message)

    def read_from_ir(self):
        while True:
            ir_message_received = self.ir_thread.read_ir()
            if self.ir_thread.is_connected() and ir_message_received:
                n_split = self.split_multitype(ir_message_received)

                for msg in n_split:
                    instr_type = self.split_cmd(msg)
                    #                    print("Message from PC: %s" % str(instr_type))

                    #IR to Android
                    if 'A' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to N7: %s" % instr_type[1])
                        ir_message_sent = self.write_to_bt(instr_type[1])

                    #IR to Arduino
                    if 'R' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to Robot: %s" % instr_type[1])
                        ir_message_sent = self.write_to_ser(instr_type[1])

                    #IR to PC
                    if 'P' in instr_type[0]:
                        print(str(datetime.now()) + " Sending to PC: %s" % instr_type[1])
                        ir_message_sent = self.write_to_pc(instr_type[1])

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
                if 'P' in instr_type[0]:
                    print(str(datetime.now()) + " Sending to PC: %s" % instr_type[1])
                    bt_message_sent = self.write_to_pc(instr_type[1])

                #N7 to Arduino
                if 'R' in instr_type[0]:
                    print(str(datetime.now()) + " Message from N7: %s" % instr_type[1])
                    bt_message_sent = self.write_to_ser(instr_type[1])

                # PC to IR
                if 'I' in instr_type[0]:
                    print(str(datetime.now()) + " Sending to IR: %s" % instr_type[1])
                    bt_message_sent = self.write_to_ir(instr_type[1])

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

                # Arduino to PC
                if 'P' in instr_type[0]:
                    print(str(datetime.now()) + " Sending to PC: %s" % instr_type[1])
                    ser_message_sent = self.write_to_pc(instr_type[1])

                # Arduino to N7
                if 'R' in instr_type[0]:
                    print(str(datetime.now()) + " Message from N7: %s" % instr_type[1])
                    ser_message_sent = self.write_to_ser(instr_type[1])

                # Arduino to IR
                if 'I' in instr_type[0]:
                    print(str(datetime.now()) + " Sending to IR: %s" % instr_type[1])
                    ser_message_sent = self.write_to_ir(instr_type[1])

                else:
                    pass
#                    print(str(datetime.now()) + " Incorrect SER Instruction Type Selected: %s" % ser_message_received)


    #Initialise threads from read/write of devices
    def initiate_threads(self):
        
        #Initialise PC WIFI threads
        read_threads_pc = threading.Thread(target=self.read_from_pc, name="pc_read_thread")
        write_threads_pc = threading.Thread(target=self.write_thread_pc, name="pc_write_thread")

        # Initialise IR WIFI threads
        read_threads_ir = threading.Thread(target=self.read_from_ir, name="ir_read_thread")
        write_threads_ir = threading.Thread(target=self.write_thread_ir, name="ir_write_thread")
        
        #Initialise N7 BT threads
        read_threads_bt = threading.Thread(target=self.read_from_bt, name="bt_read_thread")
        write_threads_bt = threading.Thread(target=self.write_thread_bt, name="bt_write_thread")
        
        #Initialise Arduino Serial threads
        read_threads_ser = threading.Thread(target=self.read_from_ser, name="ser_read_thread")
        write_threads_ser = threading.Thread(target=self.write_thread_ser, name="ser_write_thread")

        #Setting threads as Daemons
        read_threads_pc.daemon = True
        write_threads_pc.daemon = True

        read_threads_ir.daemon = True
        write_threads_ir.daemon = True

        read_threads_bt.daemon = True
        write_threads_bt.daemon = True

        read_threads_ser.daemon = True
        write_threads_ser.daemon = True
        
        read_threads_pc.start()
        write_threads_pc.start()

        read_threads_ir.start()
        write_threads_ir.start()
        
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
                        
