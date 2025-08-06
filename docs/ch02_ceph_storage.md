# Connect CEPH Storage

CEPH needs to be installed alongside incus not within.

Overall installation sequence is:

1. ceph
2. ovn
3. incus

## Required (additional) packages

- `chrony`
- `podman`
- `lvm2`
- `cephadm`
- `ceph-common`

## preparations

Ensure that all ceph hosts can connect via `ssh` PK authentication. 

```bash
ssh-keygen
ssh-copy-id 
```

## Install ceph

only the first host needs cephadmin.

follow the instructions for the first node.

check `ceph status` if the single node is working

Add new nodes with `ceph orch host add HOSTNAME IP-Address _admin`. The `HOSTNAME` must be the same as the shown by `hostname` on the node. ceph will complain if the names are not matching. 

## Disable the dashboard

Diesable the CEPH dashboard as it conflicts with the incus API endpoint later. 

```bash
ceph mgr module diable dashboard
```

## Assigning Physical Hardware



## Incus integration 

Creaate an incus cephfs pool.

```bash
ceph osd pool create incusfs_metadata
ceph osd pool create incusfs_data
ceph osd pool set incusfs_data bulk true

ceph fs new incusfs incusfs_metadata incusfs_data

# Launch the metadata service on all nodes (1 active, 2 standby)
# These services are not automatically started
ceph orch apply mds incusfs-mds 'clt-lab-n-118[012]'

# wait ...
# check if everything is in place
ceph status
```

for incus run the following commands: 

```bash
# prepare the storage on all incus hosts. 
incus storage create fspool cephfs source=incusfs --target clt-lab-n-1180
incus storage create fspool cephfs source=incusfs --target clt-lab-n-1181
incus storage create fspool cephfs source=incusfs --target clt-lab-n-1182

# create the actual storage
incus storage create fspool cephfs
```


# deleting pools

Pools cannot be easily deleted. The following steps delete the pool `my-test`:

```bash
# Activate pool deletion
ceph config set mon mon_allow_pool_delete true

# delete the actual pool
ceph osd pool delete  my-test my-test --yes-i-really-really-mean-it

# protect pools from deletion
ceph config set mon mon_allow_pool_delete false
```

## S3 Storage

## Next steps
