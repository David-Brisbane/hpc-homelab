#!/bin/bash

set -e

echo "========================================"
echo "HPC Homelab Validation"
echo "========================================"
echo

echo "[1/5] Checking Slurm controller..."
systemctl is-active --quiet slurmctld
echo "PASS: slurmctld is active"
echo

echo "[2/5] Checking Slurm nodes..."
sinfo
echo

echo "[3/5] Checking node registration..."
scontrol show nodes | grep -E 'NodeName=|State='
echo

echo "[4/5] Running single-node test..."
srun --nodes=1 --ntasks=1 hostname
echo

echo "[5/5] Running multi-node test..."
srun --nodes=2 --ntasks=2 --ntasks-per-node=1 hostname
echo

echo "========================================"
echo "HPC validation completed successfully."
echo "========================================"
