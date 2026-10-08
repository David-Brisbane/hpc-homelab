#!/bin/bash

set -e

echo "Running multi-node Slurm test..."
echo
echo "Expected: one task on compute01 and one task on compute02."
echo

srun --nodes=2 --ntasks=2 --ntasks-per-node=1 hostname

echo
echo "Multi-node Slurm test completed successfully."
