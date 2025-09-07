# Windows Python Development Environment Setup Guide

This guide will help you set up a comprehensive Python development environment on Windows for computer vision, AI, and general development projects.

## 🚀 Quick Setup Options

### Option 1: PowerShell Setup (Recommended)
```powershell
# Run the PowerShell setup script
.\setup_python_windows.ps1
```

### Option 2: Batch Setup (Simpler)
```cmd
# Run the batch setup script
setup_python_windows.bat
```

### Option 3: Manual Setup
If you prefer to set things up manually, see the detailed instructions below.

## 📋 Prerequisites

### 1. Install Python
Download and install Python from [python.org](https://python.org) or use:
```powershell
winget install Python.Python.3.11
```

### 2. Install Git (Optional but Recommended)
```powershell
winget install Git.Git
```

### 3. Install VS Code (Recommended)
```powershell
winget install Microsoft.VisualStudioCode
```

## 🛠️ What Gets Installed

The setup scripts will install:

### Core Packages
- **numpy, scipy, matplotlib** - Scientific computing and visualization
- **pandas** - Data manipulation and analysis
- **jupyter, notebook, jupyterlab** - Interactive development

### Computer Vision & AI
- **opencv-python, pillow, scikit-image** - Image processing
- **scikit-learn, tensorflow, pytorch** - Machine learning
- **torchvision, torchaudio** - PyTorch computer vision/audio

### Web Development
- **flask, fastapi, uvicorn** - Web frameworks and APIs
- **requests, aiohttp** - HTTP client libraries

### Development Tools
- **black, isort** - Code formatting
- **flake8, pylint, mypy** - Code linting and type checking
- **pytest** - Testing framework
- **ipython** - Enhanced Python shell
- **pre-commit** - Git hooks for code quality

### Utilities
- **tqdm, rich** - Progress bars and terminal formatting
- **click, typer** - Command-line interfaces
- **python-dotenv, PyYAML** - Configuration management

## 📁 Project Structure Created

```
your-project/
├── dev_env/                    # Virtual environment
├── projects/
│   ├── active/                # Current projects
│   ├── archive/               # Completed projects
│   ├── experiments/           # Quick experiments
│   └── templates/python/      # Project templates
├── scripts/                   # Utility scripts
├── .vscode/                   # VS Code configuration
├── dev_env_requirements.txt   # Frozen requirements
└── README_Windows_Dev.md      # Environment documentation
```

## 🚀 Getting Started

### 1. Run Setup
```powershell
# Navigate to your project directory
cd path\to\your\project

# Run setup (choose PowerShell or Batch)
.\setup_python_windows.ps1
# OR
setup_python_windows.bat
```

### 2. Activate Environment
```powershell
# Using the batch file
.\activate_env.bat

# Or using PowerShell (after restart)
activate
```

### 3. Start Developing
```powershell
# Start Jupyter Lab
jupyterlab

# Or Jupyter Notebook
jn

# Create a new project
newproj "my_new_project"
```

## ⚙️ VS Code Integration

The setup automatically configures VS Code with:

- **Python Interpreter**: Points to your virtual environment
- **Code Formatting**: Black for consistent formatting
- **Import Sorting**: isort for organized imports
- **Linting**: flake8 and pylint for code quality
- **Testing**: pytest integration
- **Auto-format on Save**: Enabled

## 🧪 Testing the Setup

### 1. Check Environment
```powershell
# Get environment information
Get-DevEnvInfo
```

### 2. Test Packages
```python
# Test basic imports
import numpy as np
import cv2
import torch
import tensorflow as tf
import flask
import fastapi

print("All packages imported successfully!")
```

### 3. Test Jupyter
```powershell
# Start Jupyter Lab
jupyterlab

# In Jupyter, run:
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(0, 10, 100)
y = np.sin(x)
plt.plot(x, y)
plt.show()
```

## 📝 Development Workflow

### 1. Create New Project
```powershell
newproj "my_computer_vision_project"
cd projects\active\my_computer_vision_project
```

### 2. Activate Environment
```powershell
activate
```

### 3. Install Project Dependencies
```powershell
pip install -e .
```

### 4. Develop and Test
```powershell
# Run tests
pytest

# Format code
black .
isort .

# Lint code
flake8 .
pylint src/
```

### 5. Use Jupyter for Exploration
```powershell
jupyterlab
```

## 🔧 Customization

### Adding More Packages
Edit the setup script to include additional packages:
```powershell
# In setup_python_windows.ps1, add to the install section:
pip install transformers datasets
pip install streamlit gradio
```

### Modifying VS Code Settings
Edit `.vscode\settings.json` to customize:
```json
{
    "python.formatting.blackArgs": ["--line-length", "100"],
    "python.linting.flake8Args": ["--max-line-length=100"]
}
```

## 🐛 Troubleshooting

### Virtual Environment Issues
```powershell
# Recreate virtual environment
Remove-Item -Recurse -Force dev_env
python -m venv dev_env
.\activate_env.bat
pip install -r dev_env_requirements.txt
```

### Package Installation Issues
```powershell
# Upgrade pip
python -m pip install --upgrade pip

# Install with user flag
pip install --user package_name

# Use conda if pip fails
conda install package_name
```

### Jupyter Kernel Issues
```powershell
# Remove and reinstall kernel
activate
jupyter kernelspec remove dev_env
python -m ipykernel install --user --name dev_env --display-name "Dev Environment"
```

### Permission Issues
Run PowerShell or Command Prompt as Administrator for system-level installations.

## 📚 Additional Resources

### Learning Resources
- [Python Documentation](https://docs.python.org/3/)
- [NumPy User Guide](https://numpy.org/doc/stable/user/)
- [OpenCV Tutorials](https://docs.opencv.org/)
- [PyTorch Tutorials](https://pytorch.org/tutorials/)
- [TensorFlow Guide](https://www.tensorflow.org/guide)

### Development Tools
- [VS Code Python Extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [Jupyter Extensions](https://github.com/ipython-contrib/jupyter_contrib_nbextensions)
- [Black Code Formatter](https://black.readthedocs.io/)
- [Pytest Documentation](https://docs.pytest.org/)

## 🎯 Next Steps

1. **Explore the Environment**: Try creating a simple script or Jupyter notebook
2. **Learn the Tools**: Experiment with the installed packages
3. **Build Projects**: Start with the object detection project or create your own
4. **Customize**: Add more packages and tools as needed

## 💡 Tips

- **Always activate your virtual environment** before working
- **Use Jupyter Lab** for interactive development and experimentation
- **Keep your environment up to date** with `pip install --upgrade package_name`
- **Use git** for version control on your projects
- **Document your code** with docstrings and comments

Happy coding! 🐍✨
