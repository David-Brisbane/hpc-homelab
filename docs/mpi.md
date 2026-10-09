MPI IMPLEMENTATION AND VALIDATION

OVERVIEW
Open MPI was added to the Rocky Linux 9 HPC lab to demonstrate distributed parallel execution across multiple compute nodes.
The lab uses OpenHPC packages and the GNU 14 compiler toolchain.
MPI implementation: Open MPI 5.0.7 Compiler toolchain: GNU 14.2.0 Scheduler: Slurm 25.11.8 MPI integration: Slurm PMIx plugin (pmix_v4) Shared storage: NFS-mounted /shared
INSTALLATION
The following OpenHPC packages were installed:
gnu14-compilers-ohpc openmpi5-pmix-gnu14-ohpc lmod-defaults-gnu14-openmpi5-ohpc
The matching Open MPI runtime was installed on head01, compute01 and compute02.
Environment modules are loaded using the following commands:
source /etc/profile.d/lmod.sh module load gnu14/14.2.0 module load openmpi5/5.0.7


TEST PROGRAM
Created hello_mpi.c, a basic MPI program that performs the following operations:
1. Initialises the MPI environment.
2. Retrieves each process rank using MPI_Comm_rank.
3. Retrieves the total number of processes using MPI_Comm_size.
4. Reports the hostname on which each process is running.
5. Finalises the MPI environment.
The program was compiled on head01 using:
mpicc -Wall -Wextra -O2 hello_mpi.c -o hello_mpi


Compiler options:
-Wall enables a broad set of compiler warnings. -Wextra enables additional compiler warnings. -O2 enables compiler optimisations. -o hello_mpi specifies the output executable filename.
Compilation completed successfully without warnings.
The source file and executable were placed in /shared/mpi-lab/. This directory is accessible from both compute nodes through the existing NFS shared filesystem.


SLURM EXECUTION
The MPI test was submitted as a Slurm batch job with the following resource requirements:
- Two compute nodes. 
- Two MPI tasks in total.
- One task per node.
- A two-minute time limit.
- Standard output and error logs stored under /shared/results/.

The MPI launch command used in the batch script was:
- srun --mpi=pmix_v4 /shared/mpi-lab/hello_mpi
- Slurm accepted the job with job ID 33.


OBSERVED OUTPUT
"Hello from rank 1 of 2 on compute02" 
"Hello from rank 0 of 2 on compute01"

The order of the output lines may vary because the processes execute independently.
The error output file was empty.


VALIDATION RESULTS
The successful execution demonstrated the following:
1. Slurm accepted and scheduled the MPI batch job.
2. Both compute nodes were allocated to the job.
3. Two MPI processes were launched, with one process on each node.
4. Each process received a distinct MPI rank.
5. Both processes reported the expected total process count of two.
6. The executable was accessible on both compute nodes through NFS shared storage.
7. Open MPI operated through Slurm's pmix_v4 integration.
8. The job completed successfully and its output was available on shared storage.

This validates basic multi-node MPI process launch and placement within the lab environment.


LIMITATIONS OF CURRENT TESTING
The current test demonstrates distributed process execution but does not yet validate:
MPI point-to-point message exchange. 
MPI collective communication operations. 
Performance scaling across multiple nodes. 
Hybrid MPI and OpenMP execution. 
MPI application fault tolerance.

These areas remain potential extensions of the project.


NEXT STEPS

1. Extend the test program to exchange data using MPI_Send and MPI_Recv.
2. Test collective communication using MPI_Bcast and MPI_Allreduce.
3. Compare single-node and multi-node execution.
4. Record performance measurements and identify communication overhead.
5. Document any limitations observed during further testing.
