# Connect CEPH Storage

CEPH needs to be installed alongside incus not within.

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
