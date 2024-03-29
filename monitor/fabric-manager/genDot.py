from hcloud import Client
from hcloud.server_types.domain import ServerType
from hcloud.images.domain import Image

from fabric import Connection
import json
import re
import graphviz

from dotenv import load_dotenv
import os
load_dotenv()

# connect to a single host
def getConnections(ip: str) -> list[str]:
    with Connection(ip, user="app", connect_kwargs={'key_filename': ['../../devops/sshkey']}) as conn:
        with conn.cd('~/dyneth/'):
            result = conn.run('make command CMD="admin.peers" CONFIG=fabchain', hide=True)
            peers = re.sub(r'[^a-zA-Z0-9".:\/@]([a-zA-Z0-9.]+)(?!^"):(?!^")', r'"\1":', result.stdout)
            peers = json.loads(peers, strict=False)
            # Show only ips
            return [n["network"]["remoteAddress"].split(':')[0] for n in peers]

def gatherFromNodes():
    client = Client(token=os.getenv('HCLOUD_TOKEN'))
    servers = client.servers.get_all()
    ips = [server.public_net.ipv4.ip for server in servers]
    names = {server.public_net.ipv4.ip: server.name for server in servers}
    result = {ip: getConnections(ip) for ip in ips}
    return result, names

def generateGraph(connections: dict, names: dict):
    f = graphviz.Digraph('node_connections', filename='nodes.gv')

    for i,v in connections.items():
        for j in v:
            f.edge(f'{names.get(i, i)}', f'{names.get(j,j)}')

    f.view()
if __name__ == '__main__':
    # print(json.dumps(gatherFromNodes()))
    # print(generateDot(gatherFromNodes()))
    connections, names = gatherFromNodes()
    generateGraph(connections, names)
