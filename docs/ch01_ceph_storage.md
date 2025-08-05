# Connect CEPH Storage

create a CEPH cluster on top of incus.

- 3 flexible management nodes
- 3 fixed disk nodes

Each disk node is responsible for local drives on the machine. As the disk nodes are specific to the 
hosts they are running on, each of these nodes MUST be anchored to one host.

It is possible to have separate disk nodes per drive, but this will add overhead to the entire system.
