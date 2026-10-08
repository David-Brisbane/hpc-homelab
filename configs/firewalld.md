# HPC Homelab Firewall Configuration

## Overview

The cluster uses firewalld to control network traffic between the NAT-facing network and the private HPC network.

The private VMnet1 interface is assigned to the `hpc` zone.

The NAT-facing VMnet8 interface remains in the `public` zone.

## HPC Zone

The `hpc` zone permits:

| Traffic | Protocol | Port |
|---|---|---:|
| SSH | TCP | 22 |
| Slurm controller | TCP | 6817 |
| Slurm compute daemon | TCP | 6818 |
| Slurm srun communication | TCP | 60001-60100 |

The Slurm ports are only exposed through the private HPC network.

## Slurm Controller

`head01` runs `slurmctld`.

The HPC firewall permits:

`6817/tcp`

This allows the compute nodes to communicate with the Slurm controller.

## Slurm Compute Nodes

`compute01` and `compute02` run `slurmd`.

The HPC firewall permits:

`6818/tcp`

This allows Slurm compute-node communication.

## srun Communication

The Slurm configuration defines:

SrunPortRange=60001-60100

The same TCP range is permitted through the `hpc` zone on the relevant nodes.

This is required because multi-node `srun` communication can occur directly between compute nodes.

## SSH

SSH is permitted through the `hpc` zone on TCP port 22.

Root SSH access remains disabled.

Administrative access uses the `hpcadmin` account.

## Configuration Commands

The dedicated HPC zone was created and assigned to the private interface.

SSH was permitted with:

sudo firewall-cmd --permanent --zone=hpc --add-service=ssh

Slurm controller traffic was permitted with:

sudo firewall-cmd --permanent --zone=hpc --add-port=6817/tcp

Slurm compute traffic was permitted with:

sudo firewall-cmd --permanent --zone=hpc --add-port=6818/tcp

The srun range was permitted with:

sudo firewall-cmd --permanent --zone=hpc --add-port=60001-60100/tcp

The firewall configuration was then reloaded:

sudo firewall-cmd --reload

## Validation

The active zones can be checked with:

sudo firewall-cmd --get-active-zones

The HPC zone configuration can be checked with:

sudo firewall-cmd --zone=hpc --list-all

The expected configuration includes the required SSH and Slurm ports.

## Security Model

The firewall separates external connectivity from private cluster communication.

VMnet8 provides NAT connectivity for package management and external access.

VMnet1 carries cluster traffic and is restricted by the dedicated `hpc` firewalld zone.

Only the services required for cluster operation are permitted on the private HPC network.
