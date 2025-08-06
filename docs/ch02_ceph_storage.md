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

add `.ssh/config` on host 0.

```
Host server-1
        HostName 192.168.1.81
        User multimico

Host server-2
        HostName 192.168.1.82
        User multimico

Host *
        SetEnv TERM=xterm-256color
```

This allows us to create ssh connections over the internet network.

## Install ceph

only the first host needs cephadmin.

If possible move ceph networking to a separate data-network (here `192.168.1.0`). This tells ceph that it should 
communicate via that network and not via the public network of the host. 

```bash
cephadm bootstrap --mon-ip 192.168.1.80

# Add the other hosts into the system, let ceph launch the services.
ceph orch host add clt-lab-n-1181 192.168.1.81 _admin
ceph orch host add clt-lab-n-1181 192.168.1.82 _admin
```

check `ceph status` if the single node is working

Add new nodes with `ceph orch host add HOSTNAME IP-Address _admin`. The `HOSTNAME` must be the same as the shown by `hostname` on the node. ceph will complain if the names are not matching. 

Inform ceph not to be greedy on the system resources. Otherwise the ceph will eat all memory and cpu
```bash
ceph config set mgr mgr/cephadm/autotune_memory_target_ratio 0.2
ceph config set osd osd_memory_target_autotune true
```

## Disable the dashboard

Diesable the CEPH dashboard as it conflicts with the incus API endpoint later. 

```bash
ceph mgr module diable dashboard
```

## Assigning Physical Hardware

Let ceph get all disks that are currently not used by the system. This takes a few moments before it is reflected in `ceph status`

```bash
ceph orch apply osd --all-available-devices
```

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
