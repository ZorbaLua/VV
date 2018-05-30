#!/usr/local/bin/python3
import os,socket,threading
from string import ascii_lowercase as lc

BUFFER_SIZE = 1024

def user(d):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    host = '192.168.1.6'
    port = 12345                

    s.connect((host, port))
    msg = 'signin {} {}\n'.format(d,d)
    s.send(msg.encode())
    msg = 'login {} {}\n'.format(d,d)
    s.send(msg.encode())
    msg = 'play\n'
    s.send(msg.encode())

    while 1:
        data = s.recv(BUFFER_SIZE)
        print(data.decode())

try:
    for i in range(2):
        t = threading.Thread(target=user,args=(lc[i],))
        t.start()

    while 1:
        pass
except:
   print ("ERRO A CRIAR A THREAD")



