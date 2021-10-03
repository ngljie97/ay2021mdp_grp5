import os

def init():
    global PROJ_ROOT 
    PROJ_ROOT= os.path.dirname(os.path.abspath(os.path.dirname(__file__)))