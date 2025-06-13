#!/bin/bash

# LAMMPS with Kokkos and MACE Installation Script for CSC Mahti
# Usage: ./install_lammps_kokkos_mace.sh <username>

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if username is provided
if [ $# -eq 0 ]; then
    print_error "No username provided!"
    echo "Usage: $0 <username> [project_name]"
    echo "Example: $0 myusername myproject"
    echo "Or set CSC_PROJECT environment variable: export CSC_PROJECT=myproject"
    exit 1
fi

USERNAME=$1

# Get project name from parameter or environment variable
if [ $# -ge 2 ]; then
    PROJECT_NAME=$2
elif [ -n "$CSC_PROJECT" ]; then
    PROJECT_NAME=$CSC_PROJECT
else
    print_error "No project name provided!"
    echo "Please provide project name as second parameter or set CSC_PROJECT environment variable"
    echo "Usage: $0 <username> <project_name>"
    echo "Example: $0 myusername myproject"
    echo "Or: export CSC_PROJECT=myproject && $0 myusername"
    exit 1
fi

print_status "Starting LAMMPS-KOKKOS-MACE installation for user: $USERNAME (project: $PROJECT_NAME)"

# Set up environment variables
print_status "Setting up environment variables..."
export PROJAPPL="/projappl/$PROJECT_NAME/$USERNAME/LAMMPS-KOKKOS"

print_status "Installation will be performed in: $PROJAPPL"

# Check if TMPDIR is available
if [ -z "$TMPDIR" ]; then
    print_warning "TMPDIR not set, using /tmp"
    export TMPDIR="/tmp"
fi

print_status "Using temporary directory: $TMPDIR"

# Navigate to temporary directory
print_status "Changing to temporary directory..."
cd $TMPDIR

# Download and unpack LAMMPS
print_status "Downloading LAMMPS from ACEsuit repository (MACE branch)..."
if [ -d "lammps" ]; then
    print_warning "LAMMPS directory already exists. Removing it..."
    rm -rf lammps
fi

git clone --branch=mace --depth=1 https://github.com/ACEsuit/lammps
if [ $? -ne 0 ]; then
    print_error "Failed to clone LAMMPS repository"
    exit 1
fi

print_success "LAMMPS repository cloned successfully"

# Enter LAMMPS directory
cd lammps/

# Copy cmake preset file
print_status "Copying cmake preset file for Mahti..."
cp /appl/soft/chem/lammps/custom/mahti-gpu.cmake cmake/presets/
if [ $? -ne 0 ]; then
    print_error "Failed to copy mahti-gpu.cmake preset file"
    exit 1
fi

print_success "CMake preset file copied successfully"

# Create build directory
print_status "Creating build directory..."
mkdir -p build
cd build

# Purge and load required modules
print_status "Loading required modules..."
module purge
module load gcc/11.2.0 openmpi/4.1.2 fftw/3.3.10-mpi cuda/11.5.0 cudnn/8.3.3.40-11.5 .unsupported intel-oneapi-mkl/2021.4.0

if [ $? -ne 0 ]; then
    print_error "Failed to load required modules"
    exit 1
fi

print_success "Modules loaded successfully"

# Create installation directory
print_status "Creating installation directory..."
mkdir -p $PROJAPPL/lammps-mace
if [ $? -ne 0 ]; then
    print_error "Failed to create installation directory: $PROJAPPL/lammps-mace"
    print_error "Please check if you have write permissions to the projappl directory"
    exit 1
fi

print_success "Installation directory created: $PROJAPPL/lammps-mace"

# Configure CMake
print_status "Configuring CMake build..."
cmake ../cmake \
  -C ../cmake/presets/basic.cmake \
  -C ../cmake/presets/mahti-gpu.cmake \
  -DCMAKE_INSTALL_PREFIX=$PROJAPPL/lammps-mace \
  -DCMAKE_PREFIX_PATH=$PROJAPPL/libtorch \
  -DPKG_ML-MACE=ON

if [ $? -ne 0 ]; then
    print_error "CMake configuration failed"
    exit 1
fi

print_success "CMake configuration completed successfully"

# Build LAMMPS
print_status "Building LAMMPS (this may take a while)..."
make -j 4

if [ $? -ne 0 ]; then
    print_error "LAMMPS build failed"
    exit 1
fi

print_success "LAMMPS built successfully"

# Install LAMMPS
print_status "Installing LAMMPS..."
make install

if [ $? -ne 0 ]; then
    print_error "LAMMPS installation failed"
    exit 1
fi

print_success "LAMMPS installed successfully"

# Verify installation
print_status "Verifying installation..."
if [ -f "$PROJAPPL/lammps-mace/bin/lmp" ]; then
    print_success "LAMMPS executable found at: $PROJAPPL/lammps-mace/bin/lmp"
else
    print_error "LAMMPS executable not found. Installation may have failed."
    exit 1
fi

# Print installation summary
echo ""
echo "================================================================"
print_success "LAMMPS-KOKKOS-MACE INSTALLATION COMPLETED SUCCESSFULLY!"
echo "================================================================"
echo ""
echo "Installation Details:"
echo "  Username: $USERNAME"
echo "  Project: $PROJECT_NAME"
echo "  Installation Path: $PROJAPPL/lammps-mace"
echo "  Executable: $PROJAPPL/lammps-mace/bin/lmp"
echo ""
echo "To use LAMMPS-MACE in your job scripts:"
echo "  1. Load the required modules:"
echo "     module purge"
echo "     module load gcc/10.4.0 openmpi/4.1.5-cuda fftw/3.3.10-mpi cuda/12.1.1"
echo ""
echo "  2. Set the path to your LAMMPS installation:"
echo "     export LAMMPS_PATH=$PROJAPPL/lammps-mace"
echo ""
echo "  3. Run LAMMPS with Kokkos GPU acceleration:"
echo "     \$LAMMPS_PATH/bin/lmp -k on g 1 -sf kk -pk kokkos newton on neigh half -in input.lmp"
echo ""
echo "Important Notes:"
echo "  - This build supports single GPU execution only"
echo "  - Use Mahti GPU partition for running jobs"
echo "  - Ensure your CSC project has sufficient GPU hours"
echo ""
echo "For more information, see the README.md file"
echo "================================================================"
