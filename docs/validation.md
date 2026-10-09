# HPC Cluster Validation

This document provides the validation checks used to confirm that the three-node HPC cluster is operational.

## 1. Node Connectivity

Verify that the nodes can communicate over the private HPC network.

Expected nodes:

- head01 - 10.10.10.10
- compute01 - 10.10.10.11
- compute02 - 10.10.10.12

Example checks:

ping -c 3 compute01
ping -c 3 compute02

## 2. Hostname Resolution

Verify private IPv4 hostname resolution:

getent ahostsv4 head01 compute01 compute02

Expected addresses:

10.10.10.10 head01
10.10.10.11 compute01
10.10.10.12 compute02

## 3. SSH

Verify SSH connectivity using the `hpcadmin` account.

Passwordless key authentication is configured from head01 to the compute nodes.

Example:

ssh hpcadmin@compute01 hostname
ssh hpcadmin@compute02 hostname

## 4. Munge

Verify cross-node Munge authentication from head01:

munge -n | ssh compute01 unmunge
munge -n | ssh compute02 unmunge

Expected result:

`STATUS: Success (0)`

## 5. Slurm Controller

Verify the controller service:

systemctl is-active slurmctld

Expected result:

`active`

## 6. Compute Nodes

Check node registration:

scontrol show nodes

Expected state:

- compute01: IDLE
- compute02: IDLE

Both nodes should show two configured CPUs.

## 7. Slurm Partition

Check the partition:

sinfo

Expected partition:

`compute`

The compute partition should contain:

- compute01
- compute02

## 8. Single-Node Job

Submit a basic workload:

srun --nodes=1 --ntasks=1 hostname

The command should execute on one of the compute nodes.

## 9. Multi-Node Job

Verify execution across both compute nodes:

srun --nodes=2 --ntasks=2 --ntasks-per-node=1 hostname

Expected output should contain:

compute01
compute02

This confirms that Slurm can allocate both compute nodes and launch one task on each.

## 10. Batch Job

Submit a batch script using `sbatch` and verify that the job enters the queue and completes successfully.

The resulting output should identify the allocated nodes and the nodes on which `srun` tasks execute.

## 11. Firewall

Verify the HPC firewalld zone:

sudo firewall-cmd --zone=hpc --list-all

The configuration should permit the traffic required for:

- SSH
- Slurm controller communication
- Slurm compute communication
- `srun` communication on ports 60001-60100/tcp

## 12. Reboot and Service Persistence

Reboot the cluster nodes and verify that the required services start automatically.

On head01:

systemctl is-active munge
systemctl is-active slurmctld

On each compute node:

systemctl is-active munge
systemctl is-active slurmd

Verify that both compute nodes re-register with Slurm:

sinfo
scontrol show nodes

Both compute nodes should return to the IDLE state.

Troubleshooting note: During testing, compute01 initially failed to start slurmd because its hostname was not persistent across reboot. Setting the persistent hostname to compute01 resolved the issue, and slurmd subsequently started automatically.

## 13. Node Failure and Recovery

Simulate an abrupt compute-node outage by powering off the compute01 VM in VMware Workstation without first draining it.

Monitor the node from head01:

sinfo
scontrol show node compute01

While the VM is offline, Slurm should eventually report the node as unresponsive, for example with the state IDLE+NOT_RESPONDING.

Power the VM back on and verify its services:

systemctl is-active munge
systemctl is-active slurmd

Then, from head01, confirm that the node returns to service:

sinfo
scontrol show node compute01

Finally, verify that Slurm can execute a task on the recovered node:

srun --nodes=1 --ntasks=1 --nodelist=compute01 hostname

Expected output:

compute01

Validation result: compute01 was detected as unresponsive during the simulated outage, returned to IDLE after the VM restarted, and successfully executed a targeted Slurm task without a manual RESUME operation.

This test validates node detection and recovery. Recovery of jobs interrupted by a node failure has not been tested.

## Validation Result

The cluster has passed the core validation required for the initial HPC lab milestone:

- [x] Private node connectivity
- [x] Hostname resolution
- [x] SSH key-based administration
- [x] Munge authentication
- [x] Slurm controller operation
- [x] Compute-node registration
- [x] Slurm partition
- [x] Single-node workload
- [x] Multi-node workload
- [x] Service persistence after reboot
- [x] Compute-node failure detection
- [x] Compute-node recovery after restart
- [x] Successful workload execution after recovery

The three-node Rocky Linux HPC cluster is operational and capable of scheduling workloads across both compute nodes.
