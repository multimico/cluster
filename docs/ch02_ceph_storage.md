# Connect CEPH Storage

Create a CEPH cluster on top of incus.

- 3 flexible management nodes
- 3 fixed disk nodes

Each disk node is responsible for local drives on the machine. As the disk nodes are specific to the 
hosts they are running on, each of these nodes MUST be anchored to one host.

It is possible to have separate disk nodes per drive, but this will add overhead to the entire system.

CEPH depends on podman or docker.

## Required packages

Typically missing inside the containers 

- `chrony`
- `podman`
- `lvm2`
- `cephadm`

## Memory Requirements

CEPH is memony hungry. For a three node cluster assume 3x32GB (For monitor and managers) plus  
3x16GB RAM for the disk nodes (MDS) only for the system. This takes up 48GB Ram per System. 

## Assigning Physical Hardware

## Networking

## Incus integration 

## S3 Storage

## Next steps
