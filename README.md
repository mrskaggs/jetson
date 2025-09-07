# Jetson Object Detection & AI Integration Project

A comprehensive computer vision and AI project for NVIDIA Jetson devices, featuring RealSense camera integration, object detection, and Ollama AI capabilities.

## 🚀 Quick Start

### Prerequisites
- NVIDIA Jetson device (Orin Nano Super recommended)
- Intel RealSense D435 camera
- Python 3.8+
- CUDA-compatible GPU

### Installation
1. Clone this repository
2. Run the setup script for your platform:
   ```bash
   # For Jetson devices
   ./scripts/setup_jetson.sh

   # For Windows development
   ./scripts/setup_python_windows.bat
   ```

3. Install Python dependencies:
   ```bash
   pip install -r config/requirements.txt
   ```

### Basic Usage
```bash
# Run object detection with RealSense camera
python src/object_detection_jetson.py

# Test camera and system setup
python tests/test_camera.py

# Run Ollama integration demo
python src/demo_ollama_capabilities.py
```

## 📁 Project Structure

```
├── src/                    # Main source code
│   ├── object_detection_jetson.py    # RealSense object detection
│   ├── object_detection_api.py       # API endpoints
│   ├── ollama_integration.py         # Ollama AI integration
│   └── demo_ollama_capabilities.py   # Ollama demo
├── tests/                  # Test files
│   ├── test_camera.py      # Camera functionality tests
│   └── test_environment.py # Environment tests
├── scripts/                # Setup and utility scripts
│   ├── setup_jetson.sh     # Jetson setup script
│   ├── setup_python_windows.bat
│   └── setup_python_windows.ps1
├── docs/                   # Documentation
│   ├── README_Windows_Dev.md
│   └── SETUP_GUIDE.md
├── config/                 # Configuration files
│   ├── requirements.txt    # Main dependencies
│   ├── requirements_dev.txt # Development dependencies
│   └── dev_env_requirements.txt
├── models/                 # ML model files
├── projects/               # Project templates and experiments
│   ├── active/            # Current active projects
│   ├── archive/           # Completed projects
│   ├── experiments/       # Experimental code
│   └── templates/         # Project templates
├── memory-bank/           # Project documentation and planning
└── dev_env/               # Python virtual environment
```

## 🎯 Features

### Object Detection
- Real-time object detection using MobileNet SSD
- Intel RealSense D435 depth camera integration
- CUDA acceleration for Jetson devices
- Depth measurement and 3D spatial awareness

### AI Integration
- Ollama integration for local AI models
- RESTful API for object detection services
- Extensible architecture for additional AI capabilities

### Development Tools
- Comprehensive test suite
- Cross-platform setup scripts
- Development environment configuration
- Memory bank for project documentation

## 🔧 Configuration

### Environment Setup
The project includes multiple setup configurations:

- **Jetson Production**: Optimized for NVIDIA Jetson devices
- **Windows Development**: Development environment setup
- **Virtual Environment**: Isolated Python environment with all dependencies

### Model Configuration
Place your trained models in the `models/` directory:
- `MobileNetSSD_deploy.prototxt`
- `MobileNetSSD_deploy.caffemodel`

## 🧪 Testing

Run the comprehensive test suite:
```bash
python tests/test_camera.py
```

This will test:
- Camera connectivity
- Streaming capabilities
- CUDA acceleration
- Model loading

## 📚 Documentation

Detailed documentation is available in the `docs/` directory:
- [Windows Development Setup](docs/README_Windows_Dev.md)
- [Complete Setup Guide](docs/SETUP_GUIDE.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Troubleshooting

### Common Issues
- **Camera not detected**: Ensure RealSense camera is properly connected
- **CUDA errors**: Verify CUDA installation and compatibility
- **Model files missing**: Run setup script to download required models

### Getting Help
- Check the [Setup Guide](docs/SETUP_GUIDE.md) for detailed instructions
- Review test output for specific error messages
- Ensure all dependencies are properly installed

---

**Note**: This project is designed for NVIDIA Jetson devices but can be adapted for other platforms with appropriate modifications.
