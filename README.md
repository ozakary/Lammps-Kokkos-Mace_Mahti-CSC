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
After installation, the LAMMPS executable will be located at:
```
/projappl/<project>/<username>/LAMMPS-KOKKOS/lammps-mace/bin/lmp
```
---
## Running LAMMPS with Kokkos and MACE

## Step 1: Compile the MACE Model

Before running LAMMPS, you need to compile your trained MACE model:

```bash
# Activate the virtual Python environment where MACE is installed
source /path/to/mace_env/bin/activate

# Run the MACE MLIP model compiler code
python3 create_lammps_model.py MACE_model_lr_1e-4.model
```

**What this does:**
- Converts your trained MACE model into a format compatible with LAMMPS
- Generates the model file `MACE_model_lr_1e-4.model-lammps.pt` that will be used for the LAMMPS simulation

### Step 2: Prepare Required Files

Ensure you have the following files in your working directory:

| File | Description | Source |
|------|-------------|---------|
| `xe_water_lammps.in` | LAMMPS input script | This repository |
| `lammps-gpu.sh` | SLURM job submission script | This repository |
| `xe_water.data` | Initial atomic structure in LAMMPS format | This repository |
| Compiled MACE model files | Generated from Step 1 | Created by compiler |

### Step 3: Submit the Job

Submit your simulation to the SLURM queue:

```bash
sbatch lammps-gpu.sh
```

## Output Files

After successful job submission and execution, the following output files will be generated:

### Primary Output Files

- **`log.lammps`**
  - Main LAMMPS log file containing simulation details
  - Includes thermodynamic data, timing information, and progress updates
  - Essential for monitoring simulation performance

- **`outputdata.dump`**
  - Trajectory file containing atomic positions and properties over time
  - Can be visualized using tools like OVITO, VMD, or LAMMPS tools
  - Contains the main scientific results of your simulation

### Checkpoint Files

- **`tmp.restart.<specified_steps>`**
  - Binary restart files for continuing interrupted simulations
  - Generated at specified timestep intervals
  - Useful when job wall time is reached or simulation is interrupted
  - Allows seamless continuation of long simulations

### Job Logging Files

- **`test_lammps-gpu_<JOB_ID>.out`**
  - Standard output from the SLURM job
  - Contains job execution information and LAMMPS stdout

- **`test_lammps-gpu_<JOB_ID>.err`**
  - Standard error messages from the SLURM job
  - Check this file for debugging if simulation fails

## File Usage Examples

### Analyzing Results

```bash
# View thermodynamic output
tail -f log.lammps

# Check job status
cat test_lammps-gpu_*.out

# Look for errors
cat test_lammps-gpu_*.err
```

### Continuing Simulations

If your simulation was interrupted, you can restart from a checkpoint:

```bash
# Modify your input script to read from restart file
# Add this line to your LAMMPS input:
# read_restart tmp.restart.1000000
# And remove the line:
# read_data ./xe_water.data
```

### Visualizing Trajectories

```bash
# Using OVITO (if available)
ovito outputdata.dump
```

### Advanced Analysis

```bash
# Example: Extract energy vs time
grep "Step" log.lammps | awk '{print $1, $3}' > energy.dat
```

---

## Troubleshooting Related to Building LAMMPS-KOKKOS-MACE

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
