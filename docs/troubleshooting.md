# HPC Homelab Troubleshooting

This document records significant issues encountered while building and validating the cluster.

## Munge Key Missing

### Symptom

`munge.service` failed to start on head01 because the Munge key did not exist.

### Diagnosis

The expected key was missing:

`/etc/munge/munge.key`

The installed environment did not provide the expected `mungekey` utility, so a key was generated manually.

### Resolution

A 1024-byte random key was generated and installed with the required ownership and permissions.

The same key was then distributed to the compute nodes.

Munge was subsequently started and enabled on all nodes.

### Validation

Cross-node authentication was tested from head01:

munge -n | ssh compute01 unmunge

munge -n | ssh compute02 unmunge

Both returned:

`STATUS: Success (0)`

## Munge Log Ownership

### Symptom

`munged` reported that its log file had incorrect ownership.

### Resolution

The affected Munge log directory/file ownership was corrected to the `munge` service account.

Munge then started successfully.

## Slurm Compute Node Registration

### Symptom

Initial Slurm setup required verification that the compute nodes could register with the controller.

### Diagnosis

The Slurm configuration was checked and the compute nodes were started with `slurmd`.

The controller was then queried with:

scontrol show nodes

Both compute nodes registered successfully and entered the `IDLE` state.

## Multi-Node srun Hung

### Symptom

A multi-node `srun` allocation was created successfully, but the command remained running instead of completing.

The Slurm allocation itself was therefore working.

### Investigation

Slurm and Munge were checked first.

The compute nodes had registered correctly and `slurmctld` was creating allocations.

Firewalld denied-packet logging was then enabled temporarily to identify blocked traffic.

The logs showed traffic being rejected on dynamic TCP ports.

### Root Cause

Slurm `srun` communication was not limited to traffic between the compute nodes and head01.

A compute node acting as the batch host could also receive communication from another compute node.

The existing firewall rules therefore allowed the main Slurm ports but did not allow the required dynamic `srun` communication.

### Resolution

A defined Slurm port range was configured:

SrunPortRange=60001-60100

The same TCP range was then permitted through the private `hpc` firewalld zone on the relevant nodes.

### Result

Multi-node `srun` execution completed successfully.

The following test produced output from both compute nodes:

srun --nodes=2 --ntasks=2 --ntasks-per-node=1 hostname

Result:

compute01
compute02

## Batch Host and Local Output

### Observation

A successful two-node batch allocation selected `compute01` as the batch host.

The batch script executed on `compute01`, while `srun` tasks executed across both compute nodes.

The batch output file was therefore found on `compute01`.

It was not present on `compute02`.

### Lesson

The cluster currently uses local storage on each VM rather than a shared filesystem.

A shared filesystem such as NFS would be required if all nodes needed access to the same job output or working directory.

## General Troubleshooting Approach

The cluster was debugged by separating the problem into layers:

1. Network connectivity
2. Hostname resolution
3. SSH
4. Munge authentication
5. Slurm controller
6. Compute-node registration
7. Firewall behaviour
8. Job allocation
9. Task execution

This made it possible to identify the firewall as the cause of the multi-node `srun` issue rather than changing Slurm configuration unnecessarily.
