# HPC Homelab

A 3-node Rocky Linux HPC cluster built as a hands-on infrastructure and HPC administration project.

## Cluster

| Node | Role | Private IP |
|---|---|---|
| head01 | Slurm controller / login node | 10.10.10.10 |
| compute01 | Slurm compute node | 10.10.10.11 |
| compute02 | Slurm compute node | 10.10.10.12 |

## Technologies

- Rocky Linux 9
- Slurm
- Munge
- OpenSSH
- firewalld
- VMware
- Git

## Current Status

- 3-node Rocky Linux cluster operational
- Private HPC network configured
- SSH key-based administration configured
- Munge authentication operational
- Slurm controller and compute nodes operational
- Single-node Slurm jobs tested
- Multi-node Slurm jobs successfully scheduled and executed

## Project Goals

The lab is intended to provide practical experience with Linux HPC infrastructure, cluster administration, workload scheduling, networking, security and automation.
