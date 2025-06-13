# LAMMPS with Kokkos and MACE Installation for [Mahti CSC Supercomputer](https://www.mahti.csc.fi/public/)
This repository provides installation instructions and scripts for building LAMMPS with Kokkos GPU acceleration and MACE model for ML interatomic potential support on the [Mahti CSC supercomputer](https://www.mahti.csc.fi/public/).

## Important Notes

⚠️ **Supercomputer Specific**: This installation is specifically designed for CSC Mahti supercomputer environment.

⚠️ **Single GPU Limitation**: After installation, LAMMPS-MACE will only support single-GPU execution ([more information on multi-GPU implementation](https://mace-docs.readthedocs.io/en/latest/guide/lammps_mliap.html)).

⚠️ **Project Requirement**: You need an active CSC project allocation to use this installation.

## Prerequisites

- Active CSC user account with access to Mahti
- Valid CSC project allocation
- Access to `/projappl/<project>/<username>/` directory

## Quick Installation

### Step 1: Download the Installation Script

```bash
# Clone this repository or download the script
git clone https://github.com/ozakary/Lammps-Kokkos-Mace_Mahti-CSC.git
cd Lammps-Kokkos-Mace_Mahti-CSC
chmod +x install_lammps_kokkos_mace.sh
```

### Step 2: Run the Installation

```bash
./install_lammps_kokkos_mace.sh <your_username> <your_project>
```

Replace `<your_username>` with your actual CSC username and `<your_project>` with your CSC project name.

**Alternative (using environment variable):**
```bash
export CSC_PROJECT=myproject
./install_lammps_kokkos_mace.sh myusername
```

## What the Script Does

1. **Sets up environment variables** with your username
2. **Downloads LAMMPS** from the ACEsuit repository (MACE branch)
3. **Configures build environment** with required modules:
   - gcc/10.4.0
   - openmpi/4.1.5-cuda
   - fftw/3.3.10-mpi
   - cuda/12.1.1
   - cudnn/8.3.3.40-11.5
   - intel-oneapi-mkl/2021.4.0
   - and other unsupported modules 
4. **Builds LAMMPS** with Kokkos and MACE support
5. **Installs** to your projappl directory

## Installation Directory Structure

After successful installation, you'll find:

```
/projappl/<project>/<username>/LAMMPS-KOKKOS/
├── lammps-mace/          # Installation directory
│   ├── bin/              # LAMMPS executables
│   ├── lib/              # Libraries
│   └── share/            # Documentation and examples
└── libtorch/             # PyTorch C++ library (if present)
```

## Usage

After installation, the LAMMPS executable will be located at:
```
/projappl/<project>/<username>/LAMMPS-KOKKOS/lammps-mace/bin/lmp
```

### Running LAMMPS-KOKKOS-MACE

Create a batch script for Mahti SLURM system:

```bash
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
```

## Troubleshooting

### Common Issues

**Permission denied when running script:**
```bash
chmod +x install_lammps_kokkos_mace.sh
```

**Module loading fails:**
```bash
module purge
module load gcc/11.2.0 openmpi/4.1.2 fftw/3.3.10-mpi cuda/11.5.0 cudnn/8.3.3.40-11.5 .unsupported intel-oneapi-mkl/2021.4.0
```

**Build fails:**
- Check that you have sufficient disk space in `$TMPDIR` and `PROJAPPL`
- Ensure your CSC project has adequate computing hours
- Verify that libtorch is properly installed if using PyTorch features

**Installation directory not found:**
- Ensure you have write permissions to `/projappl/<project>/<username>/`
- Check that your project allocation is active

### Getting Help

- CSC Documentation: https://docs.csc.fi/
- LAMMPS Documentation: https://docs.lammps.org/
- MACE Documentation: https://mace-docs.readthedocs.io/en/latest/index.html
- CSC Service Desk: servicedesk@csc.fi

## Dependencies

The installation automatically handles the following dependencies:
- GCC 10.4.0 compiler
- OpenMPI 4.1.5 with CUDA support
- FFTW 3.3.10 MPI version
- CUDA 12.1.1
- CMake (system default)

## Performance Notes

- This build is optimized for **single-GPU** usage on Mahti A100 GPUs
- For multi-GPU applications, consider [ML-IAP](https://mace-docs.readthedocs.io/en/latest/guide/lammps_mliap.html)
- MACE potentials may require significant GPU memory for large systems

## Contributing

If you encounter issues or have improvements:
1. Check existing issues in the repository
2. Create a new issue with detailed error messages
3. Submit pull requests for fixes or enhancements
