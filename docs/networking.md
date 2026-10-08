# HPC Homelab Networking

## Network Topology

The cluster uses two VMware virtual networks with separate purposes:

| Network | Type | Purpose | Subnet |
|---|---|---|---|
| VMnet8 | NAT | Internet and package access | 192.168.210.0/24 |
| VMnet1 | Host-only | Private HPC communication | 10.10.10.0/24 |

Each VM has one interface connected to each network.

VMnet8 provides external connectivity for DNF repositories and system updates.

VMnet1 is the private HPC network used for node-to-node communication.

## Private HPC Network

The cluster uses static private IPv4 addresses on VMnet1:

| Node | Private IP |
|---|---|
| head01 | 10.10.10.10 |
| compute01 | 10.10.10.11 |
| compute02 | 10.10.10.12 |

The Windows host uses:

10.10.10.1/24

Hostname resolution is provided locally through `/etc/hosts`:

10.10.10.10 head01
10.10.10.11 compute01
10.10.10.12 compute02

No dedicated DNS service is required for this three-node lab.

## SSH

SSH is used for cluster administration.

The `hpcadmin` account uses SSH key-based authentication between nodes.

Root SSH access is disabled.

Normal inter-node administration uses the private VMnet1 network.

## Firewall

`firewalld` is enabled on all cluster nodes.

The VMnet1 interface is assigned to a dedicated `hpc` zone, while the NAT-facing VMnet8 interface remains in the public zone.

The HPC zone permits the traffic required by the cluster:

| Traffic | Port |
|---|---|
| SSH | 22/tcp |
| Slurm controller | 6817/tcp |
| Slurm compute daemon | 6818/tcp |
| Slurm `srun` communication | 60001-60100/tcp |

Slurm is configured with:

SrunPortRange=60001-60100

The defined range allows `srun` communication to pass through the private-node firewall.

## Network Troubleshooting

During initial multi-node Slurm testing, allocations were created successfully but `srun` jobs hung.

Slurm and Munge were functioning correctly, so firewall behaviour was investigated.

Temporary firewalld denied-packet logging showed that dynamic Slurm traffic between compute nodes was being blocked.

The important finding was that Slurm task communication does not necessarily occur only between the compute nodes and `head01`. A compute node acting as the batch host can also receive traffic from another compute node.

The issue was resolved by:

1. Defining `SrunPortRange=60001-60100` in `slurm.conf`.
2. Allowing the range through the `hpc` firewalld zone.
3. Applying the rule to the relevant cluster nodes.

After the change, multi-node `srun` and batch jobs completed successfully.

## NFS Networking

Shared storage is provided by NFS over the private HPC network.

NFS traffic is restricted to the 10.10.10.0/24 cluster network. The NFS export is configured on head01 as:

/shared 10.10.10.0/24(rw,sync,no_subtree_check)

The hpc firewalld zone explicitly permits NFS traffic on head01.

The compute nodes act as NFS clients and mount:

head01:/shared

at:

/shared

The NAT/Internet-facing interface is not used for NFS traffic.

This maintains the separation between:

* VMnet8/NAT — package downloads and external connectivity
* VMnet1 — private HPC cluster communication and shared storage

### NFS Connectivity

The initial NFS mount from compute01 hung even though nfs-server was active on head01.

The cause was the cluster's firewalld configuration. The private hpc zone uses explicit service and port allowances, so NFS traffic was initially blocked.

NFS was enabled in the hpc zone rather than disabling the firewall.

After the firewall rule was applied, the compute nodes were able to mount the NFS export successfully.

## Validation

Basic private-network connectivity can be checked with:

ping -c 3 compute01
ping -c 3 compute02

IPv4 hostname resolution can be checked with:

getent ahostsv4 head01 compute01 compute02

The active firewall configuration can be reviewed with:

sudo firewall-cmd --zone=hpc --list-all
