# HPC Homelab Architecture

## Overview

This project is a three-node Rocky Linux 9 HPC cluster built on a Windows 10 laptop using VMware Workstation.

The lab provides practical experience with:

- multi-node Linux administration
- private cluster networking
- SSH-based administration
- Munge authentication
- Slurm workload management
- firewalld network security
- Git-based infrastructure documentation

The cluster consists of one head/login node and two compute nodes.

## Architecture

Windows 10 Host
└── VMware Workstation
    ├── VMnet8 - NAT
    │   └── Internet / package repository access
    │
    └── VMnet1 - Host-only
        └── Private HPC network: 10.10.10.0/24
            ├── head01
            │   └── 10.10.10.10
            │       ├── Slurm controller (slurmctld)
            │       ├── SSH login / administration
            │       └── Munge
            │
            ├── compute01
            │   └── 10.10.10.11
            │       ├── Slurm compute daemon (slurmd)
            │       └── Munge
            │
            └── compute02
                └── 10.10.10.12
                    ├── Slurm compute daemon (slurmd)
                    └── Munge

## Virtual Machines

| Node | Role | Private IP | vCPU | RAM | Disk |
|---|---|---|---:|---:|---:|
| head01 | Slurm controller / login | 10.10.10.10 | 1 | 2 GB | 20 GB |
| compute01 | Slurm compute node | 10.10.10.11 | 2 | 3 GB | 20 GB |
| compute02 | Slurm compute node | 10.10.10.12 | 2 | 3 GB | 20 GB |

## Network Interfaces

Each VM has two virtual network interfaces:

- VMnet8 for NAT connectivity and external package access
- VMnet1 for private HPC cluster communication

The private VMnet1 network is used for communication between the cluster nodes.

The Windows host has the VMnet1 address:

10.10.10.1/24

## Node Roles

### head01

head01 acts as the cluster management and login node.

It runs:

- slurmctld
- Munge
- SSH services

It is not configured as a Slurm compute node.

Users submit Slurm jobs from the head node.

### compute01

compute01 is a Slurm compute node.

It runs:

- slurmd
- Munge

It provides two virtual CPUs to Slurm for scheduled workloads.

### compute02

compute02 is a Slurm compute node.

It runs:

- slurmd
- Munge

It provides two virtual CPUs to Slurm for scheduled workloads.

## Slurm Configuration

The cluster uses a single Slurm partition:

compute

The partition contains:

compute01
compute02

The Slurm controller runs on head01.

The compute nodes register with the controller and are available for scheduled jobs.

## Authentication

Munge is used by Slurm for authentication between cluster components.

The same Munge key is installed on all three nodes.

SSH key-based authentication is configured for the hpcadmin account.

Root SSH access is disabled.

## Shared Storage

The cluster uses NFS to provide shared storage across the private HPC network.

head01 acts as the NFS server and exports /shared to the compute nodes.

* head01 — NFS server
* compute01 — NFS client
* compute02 — NFS client

The export is restricted to the private HPC subnet:

/shared 10.10.10.0/24(rw,sync,no_subtree_check)

The compute nodes mount the export as /shared.

This provides a common filesystem for job scripts, results and Slurm output, allowing workloads scheduled to different compute nodes to access the same files.

The NFS export uses root_squash, preventing root on a client node from being treated as root on the NFS server.

## Firewall Model

firewalld is enabled on the cluster nodes.

The private VMnet1 interface is assigned to a dedicated hpc firewalld zone.

The NAT-facing VMnet8 interface remains in the public zone.

The HPC zone permits the network traffic required for:

- SSH
- Slurm controller communication
- Slurm compute daemon communication
- Slurm srun task communication

## Current Project Status

The cluster has successfully demonstrated:

- node-to-node network connectivity
- SSH key-based administration
- Munge authentication
- Slurm controller operation
- Slurm compute-node registration
- single-node batch jobs
- two-node Slurm allocations
- multi-node srun execution
- firewalld-controlled HPC traffic
- nfs shared storage

The core three-node HPC scheduling milestone is operational.
