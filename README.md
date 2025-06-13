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
wget https://raw.githubusercontent.com/your-repo/install_lammps_kokkos_mace.sh
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

### Running LAMMPS-MACE

Create a batch script for Mahti SLURM system:

```bash
#!/bin/bash
#SBATCH --job-name=lammps_mace
#SBATCH --account=<your_project>
#SBATCH --partition=gpu
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:v100:1

# Load required modules
module purge
module load gcc/10.4.0 openmpi/4.1.5-cuda fftw/3.3.10-mpi cuda/12.1.1

# Set path to your LAMMPS installation
export LAMMPS_PATH=/projappl/<project>/<username>/LAMMPS-KOKKOS/lammps-mace

# Run LAMMPS
$LAMMPS_PATH/bin/lmp -k on g 1 -sf kk -pk kokkos newton on neigh half -in input.lmp
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
