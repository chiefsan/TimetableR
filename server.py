class Edge:
	def __init__(self, s, d, w, st=0):
		self.source = s
		self.destination = d
		self.weight = w
		self.status = 0
		'''
		0 -> basic
		1 -> selected
		2 -> rejected
		'''
class Fragment:
	def __init__ (self):
		self.vertices = []
		self.edges = []

	def __str__ (self):
		out = ''
		for i in self.vertices:
			out += str(i)+':'
			for j in self.edges:
				if j.source==i or j.destination==i:
					out+= '('+','.join([str(j.source), str(j.destination), str(j.weight), str(j.status)])+')'
			out+='|'
		return out

	def strToFragment (s):
		s = s.split('|')
		temp = Fragment()
		for i in s:
			i = i.split(':')
			if len(i)<2:
				return temp
			temp.vertices.append(int(i[0]))
			i = i[1]
			index = 0
			l = len(i)
			while index < l:
				if i[index]>='0' and i[index]<='9':
					if i[index-1]=='(':
						temp.edges.append(Edge(int(i[index]), int(i[index+2]), int(i[index+4]), int(i[index+6])))
				if i[index] == ')':
					index+=1
				index+=1
			temp.edges = list(set(temp.edges))
		return temp

	def merge(self, fragment):
		self.vertices += fragment.vertices
		self.edges += fragment.edges
		self.edges = list(set(self.edges))

class Graph:
	def __init__ (self, n):
		self.noOfVertices = n
		self.adjList = {}
		self.edges = []

	def addEdge (self,s, d, w):
		self.edges.append(Edge(s,d,w))
		self.edges.append(Edge(d,s,w))
		if s in self.adjList:
			self.adjList[s].append(Edge(s,d,w))
		else:
			self.adjList[s] = [Edge(s,d,w)]
		if d in self.adjList:
			self.adjList[d].append(Edge(d,s,w))
		else:
			self.adjList[d] = [Edge(d,s,w)]

import socket
from threading import Thread
from threading import Lock

global connections
global addresses
global ports
global fragments

connections = []
addresses = []
ports = []
fragments = []

a = Graph(7)
a.addEdge(0,6,7)
a.addEdge(1,2,4)
a.addEdge(1,3,2)
a.addEdge(2,4,8)
a.addEdge(3,5,1)
a.addEdge(3,6,6)
a.addEdge(4,5,3)
a.addEdge(5,6,5)

import queue

fragment_queue = queue.Queue()

fragments = []

for i in range(7):
	fragments.append(Fragment())
	fragments[i].vertices.append(i)
	fragments[i].edges = a.adjList[i]+a.adjList[i]

#print (fragments[1])
#print (Fragment.strToFragment(str(fragments[1])))

def clientHandler ():    
    connect, addr = s.accept()
    connections.append(connect)
    addresses.append(addr)
    port = addr[1]
    ports.append(port)
    #print ('connect : ', connect)
    #print ('port : ', port)

    connect.sendto(bytes(str(port), 'utf-8'), addr)
    connect.close()

working = 0
def buildMST (port, frag, lock):
	lock.acquire()
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

	s.connect(("localhost", port))
	s.send(bytes(str(frag), 'utf-8'))
	msg = s.recv(1024)
	#working -=1
	'''
	else:
		s.connect(("localhost", port))
		s.send(bytes(str(frag), 'utf-8'))
		msg = s.recv(1024)
		working -= 1
	'''
	msg = str(msg, 'utf-8')
	print (msg)
	lock.release()
	#conn.sendto(bytes(str(frag).encode('utf-8')), addr)


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('localhost', 3333))
s.listen(5)

for i in range(3):
    Thread(target = clientHandler).start()

while len(connections)<3:
	continue

lock = Lock()
noOfConnections = len(connections)

for i in range(len(fragments)):
#	if len(fragments) == 1:
		#break
	Thread(target = buildMST, args = [ports[i%noOfConnections], fragments[i], lock]).start()

'''
s = [socket.socket(socket.AF_INET, socket.SOCK_STREAM)]*noOfConnections
for i in range(noOfConnections):
	print (s[i], ports[i])
	s[i].connect(("localhost", ports[i]))
	msg = s[i].recv(1024)
	msg = str(msg, 'utf-8')
	print (msg)
	#s[i].close()
'''
#connections[1].sendto(bytes('lol', 'utf-8'), addresses[i])
'''
while len(fragments) != 1:
	for i in range(len(fragments)):
		buildMST(fragments[i%noOfConnections], connections[i%noOfConnections], addresses[i%noOfConnections])
	break
'''
print ('DONE')