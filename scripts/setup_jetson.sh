#!/bin/bash

# Setup script for Object Detection on NVIDIA Jetson Orin Nano Super with RealSense D435
# This script installs all necessary dependencies and configures the environment
# Can be run multiple times safely (idempotent)

set -e

echo "=== Object Detection Setup for Jetson Orin Nano Super ==="

# Function to check if package is installed
is_package_installed() {
    dpkg -l "$1" &> /dev/null
}

# Function to check if Python package is installed
is_python_package_installed() {
    python3 -c "import $1" &> /dev/null
}

# Update system (only if not recently updated)
echo "Checking system packages..."
if [ ! -f /var/cache/apt/pkgcache.bin ] || [ $(find /var/cache/apt/pkgcache.bin -mmin +60 2>/dev/null | wc -l) -gt 0 ]; then
    echo "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
else
    echo "System packages recently updated, skipping..."
fi

# Install system dependencies (only missing ones)
echo "Checking and installing system dependencies..."
PACKAGES_TO_INSTALL=""
for pkg in \
    build-essential \
    cmake \
    git \
    libgtk-3-dev \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    python3-dev \
    python3-pip \
    python3-numpy \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libdc1394-dev \
    libavresample-dev \
    libgphoto2-dev \
    libgomp1; do
    if ! is_package_installed "$pkg"; then
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
    fi
done

if [ -n "$PACKAGES_TO_INSTALL" ]; then
    echo "Installing missing packages:$PACKAGES_TO_INSTALL"
    sudo apt install -y $PACKAGES_TO_INSTALL
else
    echo "All system dependencies already installed"
fi

# Install OpenCV with CUDA support (if not already installed)
echo "Checking OpenCV installation..."
if ! is_package_installed "python3-opencv"; then
    echo "Installing OpenCV with CUDA support..."
    sudo apt install -y python3-opencv
else
    echo "OpenCV already installed"
fi

# Verify CUDA installation
echo "Verifying CUDA installation..."
if command -v nvcc &> /dev/null; then
    echo "CUDA found at: $(which nvcc)"
    nvcc --version
else
    echo "CUDA nvcc not found in PATH. This is normal on Jetson devices."
    echo "Checking for CUDA libraries..."
    if [ -d "/usr/local/cuda" ]; then
        echo "CUDA installation found at /usr/local/cuda"
        export PATH="/usr/local/cuda/bin${PATH:+:${PATH}}"
        export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
        echo "CUDA environment variables set"
        if command -v nvcc &> /dev/null; then
            echo "CUDA nvcc now available:"
            nvcc --version
        fi
    else
        echo "CUDA not found. On Jetson devices, CUDA should be pre-installed with JetPack."
        echo "Please ensure JetPack is properly installed."
        echo "Continuing without CUDA toolkit installation..."
    fi
fi

# Install RealSense SDK (if not already installed)
echo "Checking RealSense SDK installation..."
REALSENSE_PACKAGES_INSTALLED=true
for pkg in librealsense2-dev librealsense2-utils librealsense2-udev-rules; do
    if ! is_package_installed "$pkg"; then
        REALSENSE_PACKAGES_INSTALLED=false
        break
    fi
done

if [ "$REALSENSE_PACKAGES_INSTALLED" = false ]; then
    echo "Installing Intel RealSense SDK..."
    # Try multiple methods to add the repository
    echo "Attempting to add RealSense repository..."

    # Check if repository is already added
    if [ ! -f /etc/apt/sources.list.d/librealsense.list ]; then
        # Method 1: Try the official Intel method
        if wget -qO- https://www.intelrealsense.com/ReleaseEngineering/realsense-debian-public-key >/dev/null 2>&1; then
            sudo mkdir -p /usr/share/keyrings
            wget -qO- https://www.intelrealsense.com/ReleaseEngineering/realsense-debian-public-key | sudo gpg --dearmor -o /usr/share/keyrings/librealsense.gpg
            echo "deb [signed-by=/usr/share/keyrings/librealsense.gpg] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/librealsense.list
            echo "RealSense repository added successfully"
        else
            echo "Primary key download failed, trying alternative method..."
            # Method 2: Try alternative key location
            if wget -qO- https://librealsense.intel.com/Debian/apt-key.gpg >/dev/null 2>&1; then
                sudo mkdir -p /usr/share/keyrings
                wget -qO- https://librealsense.intel.com/Debian/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librealsense.gpg
                echo "deb [signed-by=/usr/share/keyrings/librealsense.gpg] https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/librealsense.list
                echo "RealSense repository added with alternative key"
            else
                echo "Repository key download failed. Installing RealSense from Ubuntu repository instead..."
                # Method 3: Skip custom repository and use Ubuntu packages
                echo "Using Ubuntu's default RealSense packages (may be older version)"
            fi
        fi

        # Update package list after adding repository
        sudo apt update
    else
        echo "RealSense repository already added"
    fi

    # Install RealSense packages (only missing ones)
    echo "Installing available RealSense packages..."
    PACKAGES_TO_INSTALL=""
    for pkg in librealsense2-dev librealsense2-utils librealsense2-udev-rules; do
        if ! is_package_installed "$pkg"; then
            PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL $pkg"
        fi
    done

    if [ -n "$PACKAGES_TO_INSTALL" ]; then
        sudo apt install -y $PACKAGES_TO_INSTALL
    fi

    # Try to install DKMS package if available and not already installed
    if ! is_package_installed "librealsense2-dkms" && apt-cache show librealsense2-dkms >/dev/null 2>&1; then
        echo "Installing librealsense2-dkms..."
        sudo apt install -y librealsense2-dkms
    elif is_package_installed "librealsense2-dkms"; then
        echo "librealsense2-dkms already installed"
    else
        echo "librealsense2-dkms not available in repository, skipping..."
    fi
else
    echo "RealSense SDK already installed"
fi

# Install Python dependencies
echo "Checking Python dependencies..."

# Upgrade pip if needed (check version)
echo "Checking pip version..."
CURRENT_PIP_VERSION=$(pip3 --version 2>/dev/null | sed 's/.*(\([0-9]\+\.[0-9]\+\.[0-9]\+\)).*/\1/' | head -1)
if [ -n "$CURRENT_PIP_VERSION" ]; then
    REQUIRED_PIP_VERSION="20.0.0"
    if python3 -c "
import sys
version_parts = '$CURRENT_PIP_VERSION'.split('.')
req_parts = '$REQUIRED_PIP_VERSION'.split('.')
for i in range(3):
    if int(version_parts[i]) < int(req_parts[i]):
        print('upgrade')
        sys.exit(0)
    elif int(version_parts[i]) > int(req_parts[i]):
        break
print('current')
" 2>/dev/null | grep -q "upgrade"; then
        echo "Upgrading pip..."
        pip3 install --upgrade pip
    else
        echo "Pip is up to date"
    fi
else
    echo "Could not determine pip version, upgrading to be safe..."
    pip3 install --upgrade pip
fi

# Find requirements.txt (check multiple possible locations)
if [ -f "requirements.txt" ]; then
    REQUIREMENTS_FILE="requirements.txt"
elif [ -f "../requirements.txt" ]; then
    REQUIREMENTS_FILE="../requirements.txt"
elif [ -f "../config/requirements.txt" ]; then
    REQUIREMENTS_FILE="../config/requirements.txt"
elif [ -f "../../requirements.txt" ]; then
    REQUIREMENTS_FILE="../../requirements.txt"
elif [ -f "/home/$(whoami)/projects/jetson/requirements.txt" ]; then
    REQUIREMENTS_FILE="/home/$(whoami)/projects/jetson/requirements.txt"
elif [ -f "/home/$(whoami)/projects/jetson/config/requirements.txt" ]; then
    REQUIREMENTS_FILE="/home/$(whoami)/projects/jetson/config/requirements.txt"
else
    echo "ERROR: requirements.txt not found in expected locations"
    echo "Searching for requirements.txt in common locations..."
    find /home/$(whoami) -name "requirements.txt" -type f 2>/dev/null | head -5
    echo ""
    echo "Please ensure requirements.txt exists and the script is run from the correct directory"
    exit 1
fi

echo "Using requirements file: $REQUIREMENTS_FILE"

# Install Python requirements (pip will skip already installed packages)
echo "Installing Python requirements..."
pip3 install -r "$REQUIREMENTS_FILE"

# Install Ollama for LLM integration (if not already installed)
echo "Checking Ollama installation..."
if ! command -v ollama &> /dev/null; then
    echo "Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
else
    echo "Ollama already installed"
fi

# Start Ollama service (if not already running)
echo "Checking Ollama service..."
if ! systemctl is-active --quiet ollama; then
    echo "Starting Ollama service..."
    sudo systemctl enable ollama
    sudo systemctl start ollama
    # Wait for Ollama to start
    sleep 5
else
    echo "Ollama service already running"
fi

# Pull a lightweight model for testing (if not already available)
echo "Checking for llama2 model..."
if ! ollama list | grep -q "llama2"; then
    echo "Pulling llama2 model for testing..."
    ollama pull llama2
else
    echo "llama2 model already available"
fi

# Download MobileNet SSD model files (if not already present)
echo "Checking MobileNet SSD model files..."
MODEL_DIR="models"
mkdir -p $MODEL_DIR

# Download prototxt file (using OpenCV's official repository)
if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ]; then
    echo "Downloading MobileNetSSD_deploy.prototxt..."
    wget -O $MODEL_DIR/MobileNetSSD_deploy.prototxt \
        https://raw.githubusercontent.com/opencv/opencv/master/samples/data/MobileNetSSD_deploy.prototxt

    # If OpenCV repository fails, try alternative source
    if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ]; then
        echo "OpenCV source failed, trying alternative prototxt source..."
        wget -O $MODEL_DIR/MobileNetSSD_deploy.prototxt \
            https://raw.githubusercontent.com/chuanqi305/MobileNet-SSD/master/MobileNetSSD_deploy.prototxt
    fi
else
    echo "MobileNetSSD_deploy.prototxt already exists"
fi

# Download caffemodel file (using OpenCV's official repository)
if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ]; then
    echo "Downloading MobileNetSSD_deploy.caffemodel..."
    wget -O $MODEL_DIR/MobileNetSSD_deploy.caffemodel \
        https://github.com/opencv/opencv_3rdparty/raw/dnn_samples_face_detector_20170830/res10_300x300_ssd_iter_140000.caffemodel

    # If OpenCV caffemodel fails, try alternative sources
    if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ]; then
        echo "OpenCV caffemodel failed, trying alternative source..."
        wget -O $MODEL_DIR/MobileNetSSD_deploy.caffemodel \
            https://github.com/chuanqi305/MobileNet-SSD/raw/master/MobileNetSSD_deploy.caffemodel
    fi
else
    echo "MobileNetSSD_deploy.caffemodel already exists"
fi

# Final fallback - create placeholder files if downloads fail
if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.prototxt" ]; then
    echo "WARNING: Could not download MobileNetSSD_deploy.prototxt"
    echo "You may need to download it manually from the OpenCV repository"
    echo "Creating placeholder file..."
    touch $MODEL_DIR/MobileNetSSD_deploy.prototxt
fi

if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ] || [ ! -s "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ]; then
    echo "WARNING: Could not download MobileNetSSD_deploy.caffemodel"
    echo "You may need to download it manually from a reliable source"
    echo "Creating placeholder file..."
    touch $MODEL_DIR/MobileNetSSD_deploy.caffemodel
fi

# Create data directory
mkdir -p data

# Set up udev rules for RealSense (if not already done)
echo "Checking udev rules for RealSense..."
if [ ! -f "/etc/udev/rules.d/60-librealsense2-udev-rules.rules" ]; then
    echo "Setting up udev rules for RealSense..."
    sudo cp /lib/udev/rules.d/60-librealsense2-udev-rules.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules && sudo udevadm trigger
else
    echo "RealSense udev rules already configured"
fi

# Test installations
echo "Testing installations..."

# Test Python imports
python3 -c "
import cv2
import numpy as np
import pyrealsense2 as rs
print('All Python dependencies imported successfully!')
print('OpenCV version:', cv2.__version__)
print('NumPy version:', np.__version__)
print('RealSense SDK version:', rs.__version__)
"

# Test RealSense connection
echo "Testing RealSense camera connection..."
if python3 -c "
import pyrealsense2 as rs
ctx = rs.context()
devices = ctx.query_devices()
if len(devices) > 0:
    print('RealSense camera detected:', devices[0].get_info(rs.camera_info.name))
else:
    print('No RealSense cameras detected')
"; then
    echo "RealSense test completed"
else
    echo "RealSense test failed - camera may not be connected or drivers not working"
fi

echo "=== Setup Complete ==="
echo ""
echo "To run the object detection:"
echo "1. Connect your Intel RealSense D435 camera"
echo "2. Run: python3 object_detection_jetson.py"
echo ""
echo "Model files are located in: $MODEL_DIR/"
echo "Make sure the camera is properly connected and recognized by the system."
