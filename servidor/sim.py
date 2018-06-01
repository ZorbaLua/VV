#!/usr/local/bin/python3
import os,socket,threading
from string import ascii_lowercase as lc

BUFFER_SIZE = 1024

def user(d):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    host = 'localhost'
    port = 12345                

    s.connect((host, port))
    msg = 'signin {} {}\n'.format(d,d)
    s.send(msg.encode())

    if(d == 'b'):
        msg = 'login {} {}\n'.format(d,d)
        s.send(msg.encode())
        msg = 'play\n'
        s.send(msg.encode())

        string = True
        while string!="end\n":
            data = s.recv(BUFFER_SIZE)
            string = data.decode()
            msg='press up\npress right\n'
            s.send(msg.encode())
            print(string)

    data = s.recv(BUFFER_SIZE)

try:
    for i in range(2):
        t = threading.Thread(target=user,args=(lc[i],))
        t.start()
except:
   print ("ERRO A CRIAR A THREAD")



