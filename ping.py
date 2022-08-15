from twisted.internet import reactor
from quarry.net.client import ClientFactory, ClientProtocol
import sys

class PingProtocol(ClientProtocol):
	connection_timeout = 1

	def status_response(self, data):
		for k, v in sorted(data.items()):
			if k != "favicon":
				print("%s --> %s" % (k, v))

class PingFactory(ClientFactory):
	protocol = PingProtocol
	protocol_mode_next = "status"
	connection_timeout = 0.5
	def clientConnectionFailed(self, connector, reason):
		print("connection failed:", reason.getErrorMessage())
		reactor.stop()

	def clientConnectionLost(self, connector, reason):
		print("connection lost:", reason.getErrorMessage())
		reactor.stop()

def main(argv):
	with open(argv[0]) as file:
		for line in file.readlines():
			ip = line.strip()
			print(ip)
			reactor.__init__()
			factory = PingFactory()
			reactor.connectTCP(ip, 25565, factory, timeout=1)
			reactor.run()

if __name__ == "__main__":
	main(sys.argv[1:])
