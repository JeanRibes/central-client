import requests
import sys
import socket
from subprocess import Popen


class StatusClient():
    def __init__(self, url, token, server):
        self.url = url
        self.token = token
        self.server = server
        self.status_id = self.get_id()
        self.status = self.get_self()
        self.host_id = self.status['host']

    def get_id(self):
        response = requests.get(url=self.url + '/hosts/status/me/',
                                headers={'Authorization': 'Token ' + self.token})
        id = response.text
        return id

    def get_self(self):
        res = requests.get(url=self.url + '/hosts/status/' + self.status_id + '/',
                           headers={'Authorization': 'Token ' + self.token})
        return res.json()

    def data(self, state, up):
        return {
            "id": self.status_id,
            "ip": self.get_ip(),
            "local_ip": self.get_lan_ip(),
            "up": up,
            "state": state,
            "host": self.status["host"]
        }

    def update(self, data):
        req = requests.put(url=self.url + '/hosts/status/' + self.status_id + '/', data=data,
                           headers={'Authorization': 'Token ' + self.token})
        return req

    def get_ip(self):
        return requests.get("https://jsonip.com/").json()["ip"]

    def get_lan_ip(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('10.255.255.255', 1))
        return s.getsockname()[0]

    def tunnel(self):
        p = Popen(['/usr/bin/ssh -TNR ' + str(2200 + int(self.host_id)) + ':localhost:22 '+self.server], shell=True)
        return p

    def kill_tunnel(self):
       from os import system
       system("killall ssh")


if __name__ == '__main__':
    if len(sys.argv) == 4 or len(sys.argv) == 3:
        s = StatusClient(token=sys.argv[2], url=sys.argv[1], server=sys.argv[3])
        print(s.status)
        data = s.data(state=2, up=True)
        print(s.update(data).json())
    else:
        print("Usage : " + sys.argv[0] + ' <URL without trailing slash> <token> <ssh host>')
        exit(1)
