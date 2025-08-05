This guide explains to pull up a **three node incus cluster** with OVN virtual networks. 

# Setup Ubuntu Server 

## Network preparations

For the cluster it is needed that the hosts can add virtual interfaces to the network. This is achieved by adding so called *bridged* interfaces. A bridge provides the logical structure in the linux kernel to use the same hardware with multiple virtual network interfaces (NICs). Different to other constructs, bridges have an external IP-address that can be used to connect to the host system. However, the hardware interface MUST NOT be configured. 

In netplan this looks 

```yaml
network:
    version: 2
    ethernets:
        ens1f1np1:
            dhcp4: no
    bridges:
        br-ext:
            dhcp4: yes
            interfaces:
              - ens1f1np1
``` 

> **Note** The names of the hardware interfaces depends on the system.

The same must be repeated for all interfaces that should be used by the cluster.

Replacing a hardware interface with a bridge interface does not interrupt the 
network connection. It is safe to call `sudo netplan apply` over an SSH connection. 

## Additional packages 

The following base packages should be installed: 

- openvswitch-switch
- openvswitch-switch-dpdk
- ovn-central
- ovn-host

# Bootstrap the virtual network 

> All commands require super user privileges (`sudo`)

**Step 1**: Prepare the OVN stack on all hosts. 

```bash
systemctl enable ovn-central
systemctl enable ovn-host
systemctl stop ovn-central
ip -4 a 
```

`ip -4 a` will return all IPv4 related addresses of your hosts. If you have more than 
one physical network interface. Then it makes sense to separate the internal traffic from 
the external traffic to the different NICs. 

**Step 2**: Bootstrap the cluster 

For systems with separate interfaces: Use the intenal data network for the cluster communication.

Label the first, second, and thrid node accordingly. It makes sense to reserve the IP addresses 
in a sequence and choose the lowest one as the first node.

In our case we mark the servers as following: 

```
<server_1> = 192.168.1.80
<server_2> = 192.168.1.81
<server_3> = 192.168.1.82
```

The `local` is the IP address of the node you are currently working on. 

Now edit `/etc/default/ovn-central`.

> **Hint:** Use VI and the regular expression replacements using `:%s/<server_1>/192.168.1.80/g`

On `<server_1>` enter: 

```
OVN_CTL_OPTS=" \
     --db-nb-addr=<local> \
     --db-nb-create-insecure-remote=yes \
     --db-sb-addr=<local> \
     --db-sb-create-insecure-remote=yes \
     --db-nb-cluster-local-addr=<local> \
     --db-sb-cluster-local-addr=<local> \
     --ovn-northd-nb-db=tcp:<server_1>:6641,tcp:<server_2>:6641,tcp:<server_3>:6641 \
     --ovn-northd-sb-db=tcp:<server_1>:6642,tcp:<server_2>:6642,tcp:<server_3>:6642"
```

On `<server_2>` and `<server_3>`: 

```
OVN_CTL_OPTS=" \
      --db-nb-addr=<local> \
     --db-nb-cluster-remote-addr=<server_1> \
     --db-nb-create-insecure-remote=yes \
     --db-sb-addr=<local> \
     --db-sb-cluster-remote-addr=<server_1> \
     --db-sb-create-insecure-remote=yes \
     --db-nb-cluster-local-addr=<local> \
     --db-sb-cluster-local-addr=<local> \
     --ovn-northd-nb-db=tcp:<server_1>:6641,tcp:<server_2>:6641,tcp:<server_3>:6641 \
     --ovn-northd-sb-db=tcp:<server_1>:6642,tcp:<server_2>:6642,tcp:<server_3>:6642"
```

Start OVN:

```bash
systemctl start ovn-central
```

**Step 3**: Provide the overlay endpoint in OVS on **all nodes**

This step provides the foundation for the virtual networks across the 
hosts in the cluster. 

```bash
sudo ovs-vsctl set open_vswitch . \
   external_ids:ovn-remote=tcp:<server_1>:6642,tcp:<server_2>:6642,tcp:<server_3>:6642 \
   external_ids:ovn-encap-type=geneve \
   external_ids:ovn-encap-ip=<local>
```

**Additional Hosts** 

If you expand your cluster beyound the initial three nodes, install and activate `ovn-host` 

```bash
sudo apt install ovn-host
systemctl enable ovn-host
```

Then repeat Step 3 to integrate the node into the cluster. 

# Install incus cluster

TBD

# Install incus uplink network

On the cluster manager (i.e. the frist node of the cluster) we link the local bridge interface 
of the external network to the uplink network, for each node on the cluster.

```bash
for MACHINE_NAME in "server1 server2 server3"
do 
  incus network create UPLINK --type=physical parent=br0 --target=${MACHINE_NAME}
done
```

Create the external cluster endpoint:

```bash
incus network create UPLINK --type=physical \
   ipv4.gateway=160.85.247.1/24 \
   ipv4.ovn.ranges= 160.85.247.2-160.85.247.10 \
   dns.nameservers=160.85.2.100,160.85.2.100
```

The `ipv4.gateway` requires a CIDR address. The example above shows a gateway for the 
entire `160.85.247.0`-subnet. The `ipv4.ovn.ranges` must include all ranges that OVN assign 
outcoming IP addresses to. Note that these addresses are egress only. This is useful for getting
data and more importantly updates over the internet. 

- **DO NOT** reserve the entire subnet as ovn-range. 
- **DO** reserve at least as many addresses than you expect internal networks, because
  each internal network will get its own uplink address.

It makes sense to reserve an independent block of IP adresses for ingress. 
These addresses can be used in `incus network forward`. 

## Connect OVN to incus

Incus will take over the control of OVN. We hardly interact with OVN directly.

```bash
incus config set network.ovn.northbound_connection "tcp:<server_1>:6641,tcp:<server_2>:6641,tcp:<server_3>:6641"
```

