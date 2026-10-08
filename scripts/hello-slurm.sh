#!/bin/bash
echo "Hello from Slurm"
echo "Hostname: $(hostname)"
echo "Job ID: $SLURM_JOB_ID"
echo "Node list: $SLURM_JOB_NODELIST"
echo "CPUs allocated: $SLURM_CPUS_ON_NODE"
