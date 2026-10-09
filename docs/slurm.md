# Slurm Configuration

## Overview

Slurm is the workload manager used by the cluster.

The lab uses one controller node and two compute nodes:

| Node | Role | CPUs |
|---|---|---:|
| head01 | Slurm controller / login node | 1 |
| compute01 | Slurm compute node | 2 |
| compute02 | Slurm compute node | 2 |

The cluster uses Slurm 25.11.8 from the OpenHPC repository.

## Slurm Components

### head01

head01 runs:

- `slurmctld`
- Munge
- SSH

`slurmctld` manages the cluster state and schedules workloads.

head01 is not configured as a compute node and does not run `slurmd`.

### compute01 and compute02

Both compute nodes run:

- `slurmd`
- Munge

`slurmd` registers each node with `slurmctld` and launches workloads assigned by Slurm.

## Partition

The cluster contains one partition:

`compute`

The partition contains:

- compute01
- compute02

It is the default partition for submitted jobs.

## Authentication

Slurm uses Munge for authentication between cluster components.

The same Munge key is installed on all three nodes.

Munge was tested across the private cluster network before Slurm workloads were tested.

## Resource Configuration

The compute nodes are configured with:

- compute01: 2 CPUs
- compute02: 2 CPUs

The cluster therefore provides four virtual CPUs to Slurm.

The current configuration uses `select/linear` for resource selection.

## Job Execution

Two main Slurm interfaces were used during testing.

### sbatch

`sbatch` submits a batch script to the scheduler.

The batch script itself runs once on the node selected as the batch host.

Applications can then use `srun` inside the allocation to launch tasks across the allocated nodes.

### srun

`srun` launches tasks within a Slurm allocation.

For example:

srun --nodes=2 --ntasks=2 --ntasks-per-node=1 hostname

This successfully executed one task on each compute node:

compute01
compute02

The `--nodes=2` option requests two nodes.

The `--ntasks=2` option requests two tasks.

The `--ntasks-per-node=1` option places one task on each allocated node.

## Allocation vs Execution

A Slurm allocation reserves resources, but does not automatically mean that an application is executing on every allocated node.

For example, a batch job can receive:

- two nodes
- four CPUs
- two tasks

while the batch script itself executes on a single batch host.

Using `srun` inside the allocation allows work to be launched across the allocated nodes.

This distinction was verified during testing.

## Batch Host

For multi-node batch jobs, Slurm selects one allocated compute node as the batch host.

The batch host executes the submitted batch script.

Other compute nodes can still execute tasks launched by `srun`.

Because the cluster does not currently use shared storage, batch output files are stored on the local filesystem of the batch host.

## Successful Multi-Node Test

A two-node workload was successfully submitted and executed across:

- compute01
- compute02

The resulting task placement confirmed that both compute nodes were participating in the workload.

This provides the core multi-node scheduling milestone for the project.

## Slurm and Shared Storage

NFS shared storage was integrated with the Slurm cluster.

The /shared filesystem is mounted on head01, compute01 and compute02. This provides a common location for job scripts, Slurm output and workload results.

A test workload was submitted using sbatch and configured to write its results to:

/shared/results/

Multiple jobs were submitted and successfully scheduled across both compute nodes.

Observed execution included:

* Job 17 — compute01
* Job 18 — compute01
* Job 19 — compute02
* Job 20 — compute01
* Job 21 — compute02
* Job 22 — compute01

The results were visible from the shared filesystem on head01, demonstrating that Slurm could schedule workloads to different compute nodes while NFS provided a consistent shared storage location.

This separates compute resource allocation from shared data access, providing a more realistic HPC workload environment.


## Node Availability and Recovery

Slurm node states provide operational visibility into compute-node availability.

During a controlled drain, the command below prevents new work from being scheduled on the node while existing work is allowed to finish. The reason can be recorded using the Reason field.

scontrol update NodeName=compute01 State=DRAIN Reason="Controlled node failure test"

During the failure drill, compute01 was powered off in VMware without first draining it. Slurm eventually reported:

State=IDLE+NOT_RESPONDING

The NOT_RESPONDING flag indicated that Slurm could no longer communicate with the node. The IDLE component reflected its recorded allocation state; it did not mean the powered-off node was healthy or usable.

After compute01 was powered back on, munge and slurmd started, and Slurm returned the node to IDLE without an administrator manually resuming it.

Useful inspection commands:

sinfo
scontrol show node compute01
systemctl is-active munge
systemctl is-active slurmd

A successful post-recovery test:

srun --nodes=1 --ntasks=1 --nodelist=compute01 hostname

This confirms that a task can run on the recovered node. It does not prove that a job interrupted by a node failure can resume; job requeue and application checkpoint/restart are separate behaviours that require dedicated testing.


## Current Status

The Slurm environment is operational.

Verified functionality includes:

* Slurm controller operation
* Compute-node registration and availability reporting
* Resource allocation across compute nodes
* Single-node job execution
* Two-node resource allocations
* Multi-node `srun` execution with tasks distributed across both compute nodes
* Multi-node batch workload execution
* Slurm communication permitted through the dedicated firewalld HPC zone
* Munge authentication between cluster nodes
* Automatic startup of Munge and Slurm services after reboot
* Detection of a compute-node communication failure
* Automatic return of a recovered compute node to the `IDLE` state
* Successful workload execution on a recovered compute node
* Persistent hostname configuration and recovery from a hostname-related `slurmd` startup failure
