# Windows Python Development Environment

This directory contains your Python development environment setup optimized for computer vision, AI, and general development.

## Quick Start

1. **Activate the environment:**
   ```powershell
   .\activate_env.bat
   ```

2. **Start developing:**
   ```powershell
   # Start Jupyter Lab
   jupyter lab --no-browser

   # Or Jupyter Notebook
   jupyter notebook --no-browser
   ```

3. **Create a new project:**
   ```powershell
   # Using PowerShell functions (after restart)
   newproj "my_new_project"
   ```

## Environment Info

- **Python Version:** 3.11.9
- **Virtual Environment:** dev_env
- **Jupyter Kernel:** dev_env Environment

## Installed Packages

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
- **ipython** - Enhanced Python shell (optional)

## Project Structure

```
your-project/
├── dev_env/                    # Virtual environment
├── projects/
│   ├── active/                # Currently active projects
│   ├── archive/               # Completed projects
│   ├── experiments/           # Quick experiments
│   └── templates/python/      # Project templates
├── scripts/                   # Utility scripts
├── .vscode/                   # VS Code configuration
├── dev_env_requirements.txt   # Frozen requirements
└── README_Windows_Dev.md      # This file
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `.\activate_env.bat` | Activate virtual environment |
| `jupyter lab --no-browser` | Start Jupyter Lab |
| `jupyter notebook --no-browser` | Start Jupyter Notebook |
| `newproj "name"` | Create new project from template (PowerShell) |
| `pytest` | Run tests |
| `black .` | Format code |
| `isort .` | Sort imports |
| `flake8 .` | Check code style |

## VS Code Integration

VS Code is configured with:
- **Python Interpreter**: dev_env environment
- **Code Formatting**: Black
- **Import Sorting**: isort
- **Linting**: flake8, pylint
- **Testing**: pytest
- **Auto-format on Save**: Enabled

## Development Workflow

### 1. Create New Project
```powershell
newproj "my_computer_vision_project"
cd projects\active\my_computer_vision_project
```

### 2. Activate Environment
```powershell
.\activate_env.bat
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
jupyter lab --no-browser
```

## Testing Your Environment

Run the comprehensive test suite:

```powershell
python test_environment.py
```

This will test:
- All package imports
- Core functionality (NumPy, OpenCV, TensorFlow, PyTorch)
- Project structure
- Jupyter kernel availability

## Troubleshooting

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
```

### Jupyter Kernel Issues
```powershell
# Remove and reinstall kernel
.\activate_env.bat
jupyter kernelspec remove dev_env
python -m ipykernel install --user --name dev_env --display-name "Dev Environment"
```

### Missing IPython
```powershell
# Install IPython if needed
pip install ipython
```

## Next Steps

1. **Explore the Environment**: Try creating a simple script or Jupyter notebook
2. **Learn the Tools**: Experiment with the installed packages
3. **Build Projects**: Start with the object detection project or create your own
4. **Customize**: Add more packages and tools as needed

## Current Status

✅ **Environment Setup**: Complete
✅ **Package Installation**: Complete (8/10 tests passed)
✅ **VS Code Integration**: Complete
✅ **Jupyter Setup**: Complete
✅ **Project Templates**: Complete

⚠️ **Minor Issues**:
- IPython not installed (optional)
- Can be installed with: `pip install ipython`

## Support

If you encounter issues:
1. Run `python test_environment.py` to diagnose problems
2. Check the troubleshooting section above
3. Review the setup logs for error messages
4. Ensure all prerequisites are installed

Happy coding! 🚀✨
