# Windows Python Development Environment Setup
# This script sets up a comprehensive Python development environment
# for computer vision, AI, and general development on Windows

param(
    [string]$PythonVersion = "3.11",
    [string]$VenvName = "dev_env",
    [switch]$SkipGitSetup,
    [switch]$SkipVSCodeExtensions
)

Write-Host "🐍 Setting up Python Development Environment for Windows" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Yellow

# Check if running as administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Some operations may require administrator privileges." -ForegroundColor Yellow
    Write-Host "   Consider running as administrator for full functionality." -ForegroundColor Yellow
}

# Function to check if command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check Python installation
Write-Host "🔍 Checking Python installation..." -ForegroundColor Cyan
$pythonInstalled = Test-Command "python"
$python3Installed = Test-Command "python3"
$pyInstalled = Test-Command "py"

if ($python3Installed) {
    $pythonCmd = "python3"
    Write-Host "✅ Python3 found" -ForegroundColor Green
} elseif ($pythonInstalled) {
    $pythonCmd = "python"
    Write-Host "✅ Python found" -ForegroundColor Green
} elseif ($pyInstalled) {
    $pythonCmd = "py"
    Write-Host "✅ Python launcher (py) found" -ForegroundColor Green
} else {
    Write-Host "❌ Python not found!" -ForegroundColor Red
    Write-Host "Please install Python from: https://python.org" -ForegroundColor Yellow
    Write-Host "Or use: winget install Python.Python.3.11" -ForegroundColor Yellow
    exit 1
}

# Check Python version
Write-Host "📋 Checking Python version..." -ForegroundColor Cyan
try {
    $pythonVersion = & $pythonCmd --version 2>&1
    Write-Host "Python version: $pythonVersion" -ForegroundColor Green

    # Extract version number
    $versionMatch = $pythonVersion | Select-String -Pattern "Python (\d+)\.(\d+)\.(\d+)"
    if ($versionMatch) {
        $major = [int]$versionMatch.Matches[0].Groups[1].Value
        $minor = [int]$versionMatch.Matches[0].Groups[2].Value

        if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
            Write-Host "⚠️  Python version is old. Consider upgrading to Python 3.8+" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "❌ Could not determine Python version" -ForegroundColor Red
}

# Upgrade pip
Write-Host "⬆️ Upgrading pip..." -ForegroundColor Cyan
try {
    & $pythonCmd -m pip install --upgrade pip
    Write-Host "✅ Pip upgraded successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not upgrade pip" -ForegroundColor Yellow
}

# Create virtual environment
Write-Host "🏠 Creating virtual environment: $VenvName" -ForegroundColor Cyan
$venvPath = Join-Path $PWD $VenvName

if (Test-Path $venvPath) {
    Write-Host "⚠️  Virtual environment already exists at $venvPath" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to recreate it? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        Remove-Item -Recurse -Force $venvPath
    } else {
        Write-Host "Using existing virtual environment" -ForegroundColor Green
    }
}

if (-not (Test-Path $venvPath)) {
    try {
        & $pythonCmd -m venv $venvPath
        Write-Host "✅ Virtual environment created at $venvPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create virtual environment" -ForegroundColor Red
        exit 1
    }
}

# Activate virtual environment and install packages
Write-Host "📦 Activating virtual environment and installing packages..." -ForegroundColor Cyan

$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
$pipCmd = Join-Path $venvPath "Scripts\pip.exe"
$pythonVenvCmd = Join-Path $venvPath "Scripts\python.exe"

# Create activation script for package installation
$installScript = @"
# Activate virtual environment
& "$activateScript"

# Upgrade pip in virtual environment
& "$pipCmd" install --upgrade pip setuptools wheel

# Install core scientific packages
Write-Host "Installing core packages..." -ForegroundColor Cyan
& "$pipCmd" install numpy scipy matplotlib

# Install computer vision packages
Write-Host "Installing computer vision packages..." -ForegroundColor Cyan
& "$pipCmd" install opencv-python pillow scikit-image

# Install machine learning packages
Write-Host "Installing machine learning packages..." -ForegroundColor Cyan
& "$pipCmd" install scikit-learn tensorflow
& "$pipCmd" install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install data science packages
Write-Host "Installing data science packages..." -ForegroundColor Cyan
& "$pipCmd" install pandas jupyter notebook jupyterlab
& "$pipCmd" install seaborn plotly bokeh

# Install web development packages
Write-Host "Installing web development packages..." -ForegroundColor Cyan
& "$pipCmd" install flask flask-cors fastapi uvicorn
& "$pipCmd" install requests aiohttp

# Install development tools
Write-Host "Installing development tools..." -ForegroundColor Cyan
& "$pipCmd" install ipython black isort flake8 pylint mypy
& "$pipCmd" install pytest pytest-cov pytest-xdist
& "$pipCmd" install pre-commit

# Install additional utilities
Write-Host "Installing utilities..." -ForegroundColor Cyan
& "$pipCmd" install tqdm rich click typer
& "$pipCmd" install python-dotenv pyyaml toml
& "$pipCmd" install schedule APScheduler

# Install project-specific packages
Write-Host "Installing project-specific packages..." -ForegroundColor Cyan
& "$pipCmd" install -r requirements.txt

# Create requirements file
Write-Host "Creating requirements file..." -ForegroundColor Cyan
& "$pipCmd" freeze > "${VenvName}_requirements.txt"

Write-Host "✅ All packages installed successfully!" -ForegroundColor Green
"@

# Execute the installation script
try {
    Invoke-Expression $installScript
} catch {
    Write-Host "❌ Error during package installation: $_" -ForegroundColor Red
}

# Setup Jupyter kernel
Write-Host "📓 Setting up Jupyter kernel..." -ForegroundColor Cyan
try {
    $kernelScript = @"
& "$activateScript"
& "$pythonVenvCmd" -m ipykernel install --user --name $VenvName --display-name "$VenvName Environment"
"@
    Invoke-Expression $kernelScript
    Write-Host "✅ Jupyter kernel installed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not install Jupyter kernel" -ForegroundColor Yellow
}

# Setup Git (optional)
if (-not $SkipGitSetup) {
    Write-Host "🔧 Setting up Git configuration..." -ForegroundColor Cyan

    if (Test-Command "git") {
        # Check if Git is configured
        $gitConfig = git config --list --local 2>$null
        if (-not $gitConfig) {
            Write-Host "Git is not configured. Let's set it up:" -ForegroundColor Yellow
            $gitName = Read-Host "Enter your Git name"
            $gitEmail = Read-Host "Enter your Git email"

            if ($gitName -and $gitEmail) {
                git config --global user.name $gitName
                git config --global user.email $gitEmail
                git config --global core.editor "code --wait"
                git config --global init.defaultBranch main
                Write-Host "✅ Git configured successfully" -ForegroundColor Green
            }
        } else {
            Write-Host "✅ Git is already configured" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Git not found. Install from: https://git-scm.com" -ForegroundColor Yellow
    }
}

# Create development directory structure
Write-Host "📁 Creating development directory structure..." -ForegroundColor Cyan

$dirs = @(
    "projects\active",
    "projects\archive",
    "projects\experiments",
    "projects\templates\python",
    "scripts",
    ".vscode"
)

foreach ($dir in $dirs) {
    $fullPath = Join-Path $PWD $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    }
}

Write-Host "✅ Directory structure created" -ForegroundColor Green

# Create VS Code settings
Write-Host "⚙️ Creating VS Code configuration..." -ForegroundColor Cyan

$vscodeSettings = @"
{
    "python.defaultInterpreterPath": "${venvPath}\\Scripts\\python.exe",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length", "88"],
    "python.sortImports.args": ["--profile", "black"],
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "jupyter.notebookFileRoot": "`${workspaceFolder}",
    "files.associations": {
        "*.py": "python"
    },
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false
}
"@

$vscodeSettingsPath = Join-Path $PWD ".vscode\settings.json"
$vscodeSettings | Out-File -FilePath $vscodeSettingsPath -Encoding UTF8

# Create Python project template
Write-Host "📋 Creating Python project template..." -ForegroundColor Cyan

$templateDir = Join-Path $PWD "projects\templates\python"

$pyprojectToml = @"
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my_project"
version = "0.1.0"
description = "A Python project"
authors = [{name = "Your Name", email = "your.email@example.com"}]
dependencies = [
    "numpy",
    "opencv-python",
    "flask",
]

[project.optional-dependencies]
dev = [
    "black",
    "isort",
    "flake8",
    "pytest",
    "pytest-cov",
]

[tool.black]
line-length = 88
target-version = ['py38']

[tool.isort]
profile = "black"
multi_line_output = 3

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
"@

$pyprojectToml | Out-File -FilePath (Join-Path $templateDir "pyproject.toml") -Encoding UTF8

# Create template files
$templateFiles = @(
    @{Path = "src\__init__.py"; Content = '"""Main package for the project."""`n__version__ = "0.1.0"'},
    @{Path = "src\main.py"; Content = '"""Main entry point for the application."""`n`n`ndef main():`n    """Main function."""`n    print("Hello, World!")`n`n`nif __name__ == "__main__":`n    main()'},
    @{Path = "tests\__init__.py"; Content = '"""Test package."""'},
    @{Path = "tests\test_main.py"; Content = '"""Tests for main module."""`n`nimport pytest`nfrom src.main import main`n`n`ndef test_main(capsys):`n    """Test main function."""`n    main()`n    captured = capsys.readouterr()`n    assert "Hello, World!" in captured.out'},
    @{Path = "README.md"; Content = '# My Project`n`nA Python project.`n`n## Setup`n`n```bash`n# Create virtual environment`npython -m venv venv`nvenv\Scripts\activate`n`n# Install dependencies`npip install -e .`n```'}
)

foreach ($file in $templateFiles) {
    $filePath = Join-Path $templateDir $file.Path
    $dir = Split-Path $filePath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $file.Content | Out-File -FilePath $filePath -Encoding UTF8
}

# Create PowerShell profile additions
Write-Host "🔗 Creating PowerShell profile additions..." -ForegroundColor Cyan

$profileAdditions = @"

# Python Development Environment
function Activate-DevEnv {
    & "$venvPath\Scripts\Activate.ps1"
}

function New-PythonProject {
    param([string]`$Name)
    `$source = Join-Path "$PWD" "projects\templates\python"
    `$destination = Join-Path "$PWD" "projects\active\$Name"
    Copy-Item -Recurse `$source `$destination
    Write-Host "Project created at: `$destination" -ForegroundColor Green
}

function Start-JupyterLab {
    Activate-DevEnv
    jupyter lab --no-browser
}

function Start-JupyterNotebook {
    Activate-DevEnv
    jupyter notebook --no-browser
}

# Useful aliases
Set-Alias activate Activate-DevEnv
Set-Alias jupyterlab Start-JupyterLab
Set-Alias jn Start-JupyterNotebook
Set-Alias newproj New-PythonProject

# Quick environment info
function Get-DevEnvInfo {
    Write-Host "=== Development Environment Info ===" -ForegroundColor Green
    Write-Host "Python: " -NoNewline
    try { & python --version } catch { Write-Host "Not found" -ForegroundColor Red }
    Write-Host "Virtual Environment: $venvPath" -ForegroundColor Cyan
    Write-Host "Project Root: $PWD" -ForegroundColor Cyan
}
"@

$profilePath = $PROFILE
if ($profilePath) {
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    # Check if our additions are already in the profile
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -notlike "*Python Development Environment*") {
        Add-Content -Path $profilePath -Value $profileAdditions
        Write-Host "✅ PowerShell profile updated" -ForegroundColor Green
        Write-Host "   Restart PowerShell or run: . `$PROFILE" -ForegroundColor Yellow
    } else {
        Write-Host "✅ PowerShell profile already configured" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  Could not find PowerShell profile path" -ForegroundColor Yellow
}

# Create environment documentation
Write-Host "📖 Creating environment documentation..." -ForegroundColor Cyan

$readmeContent = @"
# Windows Python Development Environment

This directory contains your Python development environment setup optimized for computer vision, AI, and general development.

## Quick Start

1. **Activate the environment:**
   ```powershell
   activate
   ```

2. **Start developing:**
   ```powershell
   # Start Jupyter Lab
   jupyterlab

   # Or Jupyter Notebook
   jn
   ```

3. **Create a new project:**
   ```powershell
   newproj "my_new_project"
   ```

## Environment Info

- **Python Version:** Check with `python --version`
- **Virtual Environment:** $VenvName ($venvPath)
- **Jupyter Kernel:** $VenvName Environment

## Installed Packages

### Core Packages
- numpy, scipy, matplotlib
- pandas, jupyter, notebook, jupyterlab

### Computer Vision & AI
- opencv-python, scikit-image, pillow
- scikit-learn, tensorflow, pytorch
- torchvision, torchaudio

### Web Development
- flask, fastapi, uvicorn
- requests, aiohttp

### Development Tools
- black, isort, flake8, pylint, mypy
- pytest, pytest-cov, pre-commit
- ipython

## Project Structure

```
projects/
├── active/          # Currently active projects
├── archive/         # Completed projects
├── experiments/     # Quick experiments
└── templates/       # Project templates
scripts/             # Utility scripts
$VenvName/          # Virtual environment
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `activate` | Activate virtual environment |
| `jupyterlab` | Start Jupyter Lab |
| `jn` | Start Jupyter Notebook |
| `newproj <name>` | Create new project from template |
| `Get-DevEnvInfo` | Show environment information |

## VS Code Integration

VS Code is configured with:
- Python interpreter: $VenvName environment
- Code formatting: Black
- Import sorting: isort
- Linting: flake8, pylint
- Testing: pytest

## Development Workflow

1. **Create project:** `newproj "project_name"`
2. **Navigate:** `cd projects\active\project_name`
3. **Activate:** `activate`
4. **Install:** `pip install -e .`
5. **Develop:** Use VS Code or Jupyter
6. **Test:** `pytest`
7. **Format:** Code is auto-formatted on save

## Troubleshooting

### Virtual Environment Issues
```powershell
# Recreate virtual environment
Remove-Item -Recurse -Force $VenvName
python -m venv $VenvName
activate
pip install -r ${VenvName}_requirements.txt
```

### Package Installation Issues
```powershell
# Upgrade pip
python -m pip install --upgrade pip

# Install with user flag if needed
pip install --user package_name
```

### Jupyter Kernel Issues
```powershell
# Remove and reinstall kernel
activate
jupyter kernelspec remove $VenvName
python -m ipykernel install --user --name $VenvName --display-name "$VenvName Environment"
```

## Next Steps

1. Restart PowerShell to load profile changes
2. Open VS Code in this directory
3. Try creating a test project: `newproj "test_project"`
4. Start Jupyter Lab: `jupyterlab`

Happy coding! 🚀
"@

$readmeContent | Out-File -FilePath (Join-Path $PWD "README_Windows_Dev.md") -Encoding UTF8

# Create batch file for easy activation
Write-Host "📄 Creating batch file for easy activation..." -ForegroundColor Cyan

$batchContent = @"
@echo off
echo Activating Python development environment...
call "$venvPath\Scripts\activate.bat"
echo.
echo Environment activated! You can now use:
echo - python, pip, jupyter
echo - All installed packages
echo.
echo To deactivate, type: deactivate
echo.
cmd /k
"@

$batchContent | Out-File -FilePath (Join-Path $PWD "activate_env.bat") -Encoding ASCII

# Final summary
Write-Host "`n🎉 Python Development Environment Setup Complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Yellow
Write-Host "Environment: $VenvName" -ForegroundColor Cyan
Write-Host "Location: $venvPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Quick Start Commands:" -ForegroundColor Green
Write-Host "  • Activate environment: .\activate_env.bat" -ForegroundColor White
Write-Host "  • Or in PowerShell: activate" -ForegroundColor White
Write-Host "  • Start Jupyter Lab: jupyterlab" -ForegroundColor White
Write-Host "  • Create project: newproj 'my_project'" -ForegroundColor White
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Green
Write-Host "  1. Restart PowerShell to load profile changes" -ForegroundColor White
Write-Host "  2. Try: Get-DevEnvInfo" -ForegroundColor White
Write-Host "  3. Open VS Code and start developing!" -ForegroundColor White
Write-Host ""
Write-Host "Documentation: README_Windows_Dev.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Happy coding! 🐍" -ForegroundColor Magenta
