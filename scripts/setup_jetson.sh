#!/bin/bash

# Setup script for Object Detection on NVIDIA Jetson Orin Nano Super with RealSense D435
# This script installs all necessary dependencies and configures the environment

set -e

echo "=== Object Detection Setup for Jetson Orin Nano Super ==="

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install system dependencies
echo "Installing system dependencies..."
sudo apt install -y \
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
    libdc1394-22-dev \
    libavresample-dev \
    libgphoto2-dev \
    libgomp1

# Install OpenCV with CUDA support
echo "Installing OpenCV with CUDA support..."
sudo apt install -y python3-opencv

# Verify CUDA installation
echo "Verifying CUDA installation..."
if ! command -v nvcc &> /dev/null; then
    echo "CUDA not found. Installing CUDA toolkit..."
    # Install CUDA toolkit for Jetson
    sudo apt install -y nvidia-cuda-toolkit
fi

# Install RealSense SDK
echo "Installing Intel RealSense SDK..."
# Add Intel repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
sudo add-apt-repository "deb https://librealsense.intel.com/Debian/apt-repo $(lsb_release -cs) main" -u

# Install RealSense packages
sudo apt install -y \
    librealsense2-dev \
    librealsense2-utils \
    librealsense2-dkms \
    librealsense2-udev-rules

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install -r requirements.txt

# Install Ollama for LLM integration
echo "Installing Ollama..."
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama service
echo "Starting Ollama service..."
sudo systemctl enable ollama
sudo systemctl start ollama

# Wait for Ollama to start
sleep 5

# Pull a lightweight model for testing
echo "Pulling llama2 model for testing..."
ollama pull llama2

# Download MobileNet SSD model files
echo "Downloading MobileNet SSD model files..."
MODEL_DIR="models"
mkdir -p $MODEL_DIR

# Download prototxt file
wget -O $MODEL_DIR/MobileNetSSD_deploy.prototxt \
    https://raw.githubusercontent.com/chuanqi305/MobileNet-SSD/master/MobileNetSSD_deploy.prototxt

# Download caffemodel file
wget -O $MODEL_DIR/MobileNetSSD_deploy.caffemodel \
    https://drive.google.com/uc?export=download&id=0B3gersZ2cHIxRm5PMWRoTkdHdHc

# Alternative download for caffemodel (if Google Drive link doesn't work)
if [ ! -f "$MODEL_DIR/MobileNetSSD_deploy.caffemodel" ]; then
    echo "Primary download failed, trying alternative source..."
    wget -O $MODEL_DIR/MobileNetSSD_deploy.caffemodel \
        https://github.com/chuanqi305/MobileNet-SSD/raw/master/MobileNetSSD_deploy.caffemodel
fi

# Create data directory
mkdir -p data

# Set up udev rules for RealSense (if not already done)
echo "Setting up udev rules for RealSense..."
sudo cp /lib/udev/rules.d/60-librealsense2-udev-rules.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

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
