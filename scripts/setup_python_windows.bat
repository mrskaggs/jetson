@echo off
REM Windows Python Development Environment Setup (Batch Version)
REM This is a simpler batch file version of the PowerShell setup

echo 🚀 Setting up Python Development Environment for Windows
echo ========================================================

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python not found!
    echo Please install Python from: https://python.org
    echo Or use: winget install Python.Python.3.11
    pause
    exit /b 1
)

echo ✅ Python found
python --version

REM Create virtual environment
echo 🏠 Creating virtual environment...
if exist dev_env (
    echo ⚠️ Virtual environment already exists
    set /p choice="Recreate it? (y/N): "
    if /i "!choice!"=="y" (
        rmdir /s /q dev_env
    )
)

if not exist dev_env (
    python -m venv dev_env
    if %errorlevel% neq 0 (
        echo ❌ Failed to create virtual environment
        pause
        exit /b 1
    )
    echo ✅ Virtual environment created
)

REM Activate and install packages
echo 📦 Installing packages...
call dev_env\Scripts\activate.bat

python -m pip install --upgrade pip setuptools wheel

echo Installing core packages...
pip install numpy scipy matplotlib

echo Installing computer vision packages...
pip install opencv-python pillow scikit-image

echo Installing machine learning packages...
pip install scikit-learn tensorflow
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

echo Installing data science packages...
pip install pandas jupyter notebook jupyterlab
pip install seaborn plotly bokeh

echo Installing web development packages...
pip install flask flask-cors fastapi uvicorn
pip install requests aiohttp

echo Installing development tools...
pip install ipython black isort flake8 pylint mypy
pip install pytest pytest-cov pytest-xdist
pip install pre-commit

echo Installing utilities...
pip install tqdm rich click typer
pip install python-dotenv pyyaml toml
pip install schedule APScheduler

echo Installing project-specific packages...
if exist requirements.txt (
    pip install -r requirements.txt
)

REM Create requirements file
pip freeze > dev_env_requirements.txt

REM Setup Jupyter kernel
echo 📓 Setting up Jupyter kernel...
python -m ipykernel install --user --name dev_env --display-name "Dev Environment"
if %errorlevel% neq 0 (
    echo ⚠️ Could not install Jupyter kernel
)

REM Create directory structure
echo 📁 Creating directory structure...
if not exist projects\active mkdir projects\active
if not exist projects\archive mkdir projects\archive
if not exist projects\experiments mkdir projects\experiments
if not exist projects\templates\python mkdir projects\templates\python
if not exist scripts mkdir scripts
if not exist .vscode mkdir .vscode

echo ✅ Setup complete!

echo.
echo 🎉 Python Development Environment Setup Complete!
echo =================================================
echo.
echo Quick Start:
echo   1. Activate: dev_env\Scripts\activate.bat
echo   2. Jupyter Lab: jupyter lab --no-browser
echo   3. Jupyter Notebook: jupyter notebook --no-browser
echo.
echo To create a new project:
echo   xcopy projects\templates\python projects\active\my_project /E /I /H
echo.
echo Happy coding! 🐍
echo.
pause
