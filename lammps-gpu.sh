#!/bin/bash
#SBATCH --account=plantto
#SBATCH --partition=gputest
#SBATCH --time=00:15:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:a100:1
#SBATCH --output=test_lammps-gpu_%j.out
#SBATCH --error=test_lammps-gpu_%j.err

module purge
module load gcc/11.2.0 openmpi/4.1.2 fftw/3.3.10-mpi cuda/11.5.0 cudnn/8.3.3.40-11.5 .unsupported intel-oneapi-mkl/2021.4.0

# Set the installation directory of LAMMPS and libtorch (replace <project> and <username> with your CSC project and username below)
LAMMPS_DIR=/projappl/<project>/<username>/LAMMPS-KOKKOS/lammps-mace
LIBTORCH_DIR=/projappl/<project>/<username>/LAMMPS-KOKKOS/libtorch

# Ensure the directory containing libtorch.so is included in the LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LIBTORCH_DIR/lib:$FFTW_INSTALL_ROOT/lib:$CUDA_INSTALL_ROOT/lib64:$LD_LIBRARY_PATH

export PATH=$LAMMPS_DIR/bin:$PATH

export OMP_NUM_THREADS=1

srun -n 1 lmp -sf kk -k on g 4 -pk kokkos -in xe_water_lammps.in
