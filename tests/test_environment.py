#!/usr/bin/env python3
"""
Comprehensive test script for the Python development environment
Tests all major packages and functionality
"""

import sys
import platform
import subprocess
import importlib
import time
from pathlib import Path

def print_header(text):
    """Print a formatted header"""
    print(f"\n{'='*60}")
    print(f"🧪 {text}")
    print(f"{'='*60}")

def print_success(text):
    """Print a success message"""
    print(f"✅ {text}")

def print_error(text):
    """Print an error message"""
    print(f"❌ {text}")

def print_warning(text):
    """Print a warning message"""
    print(f"⚠️  {text}")

def test_basic_imports():
    """Test basic package imports"""
    print_header("Testing Basic Package Imports")

    basic_packages = [
        'numpy',
        'scipy',
        'matplotlib',
        'pandas',
        'jupyter',
        'notebook',
        'jupyterlab'
    ]

    success_count = 0
    for package in basic_packages:
        try:
            importlib.import_module(package)
            print_success(f"{package} imported successfully")
            success_count += 1
        except ImportError as e:
            print_error(f"Failed to import {package}: {e}")

    print(f"\nBasic packages: {success_count}/{len(basic_packages)} successful")
    return success_count == len(basic_packages)

def test_cv_ai_imports():
    """Test computer vision and AI package imports"""
    print_header("Testing Computer Vision & AI Packages")

    cv_ai_packages = [
        'cv2',
        'PIL',
        'skimage',
        'sklearn',
        'tensorflow',
        'torch',
        'torchvision'
    ]

    success_count = 0
    for package in cv_ai_packages:
        try:
            if package == 'PIL':
                import PIL
            elif package == 'cv2':
                import cv2
            elif package == 'sklearn':
                import sklearn
            elif package == 'skimage':
                import skimage
            else:
                importlib.import_module(package)
            print_success(f"{package} imported successfully")
            success_count += 1
        except ImportError as e:
            print_error(f"Failed to import {package}: {e}")

    print(f"\nCV/AI packages: {success_count}/{len(cv_ai_packages)} successful")
    return success_count == len(cv_ai_packages)

def test_web_dev_imports():
    """Test web development package imports"""
    print_header("Testing Web Development Packages")

    web_packages = [
        'flask',
        'fastapi',
        'uvicorn',
        'requests',
        'aiohttp'
    ]

    success_count = 0
    for package in web_packages:
        try:
            importlib.import_module(package)
            print_success(f"{package} imported successfully")
            success_count += 1
        except ImportError as e:
            print_error(f"Failed to import {package}: {e}")

    print(f"\nWeb packages: {success_count}/{len(web_packages)} successful")
    return success_count == len(web_packages)

def test_dev_tools():
    """Test development tools"""
    print_header("Testing Development Tools")

    dev_tools = [
        'black',
        'isort',
        'flake8',
        'pylint',
        'mypy',
        'pytest',
        'ipython'
    ]

    success_count = 0
    for tool in dev_tools:
        try:
            importlib.import_module(tool)
            print_success(f"{tool} imported successfully")
            success_count += 1
        except ImportError as e:
            print_error(f"Failed to import {tool}: {e}")

    print(f"\nDev tools: {success_count}/{len(dev_tools)} successful")
    return success_count == len(dev_tools)

def test_numpy_functionality():
    """Test NumPy functionality"""
    print_header("Testing NumPy Functionality")

    try:
        import numpy as np

        # Basic array operations
        arr = np.array([1, 2, 3, 4, 5])
        mean_val = np.mean(arr)
        std_val = np.std(arr)

        print_success(f"NumPy array creation: {arr}")
        print_success(f"Mean calculation: {mean_val}")
        print_success(f"Standard deviation: {std_val}")

        # Matrix operations
        matrix = np.random.rand(3, 3)
        inv_matrix = np.linalg.inv(matrix)
        print_success("Matrix inversion successful")

        return True
    except Exception as e:
        print_error(f"NumPy functionality test failed: {e}")
        return False

def test_opencv_functionality():
    """Test OpenCV functionality"""
    print_header("Testing OpenCV Functionality")

    try:
        import cv2
        import numpy as np

        # Create a simple image
        img = np.zeros((100, 100, 3), dtype=np.uint8)
        img[:, :, 0] = 255  # Blue channel

        # Basic image operations
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)

        print_success(f"OpenCV version: {cv2.__version__}")
        print_success("Image creation and processing successful")

        return True
    except Exception as e:
        print_error(f"OpenCV functionality test failed: {e}")
        return False

def test_tensorflow_pytorch():
    """Test TensorFlow and PyTorch functionality"""
    print_header("Testing ML Framework Functionality")

    tf_success = False
    torch_success = False

    # Test TensorFlow
    try:
        import tensorflow as tf
        print_success(f"TensorFlow version: {tf.__version__}")

        # Simple tensor operation
        a = tf.constant([[1, 2], [3, 4]])
        b = tf.constant([[5, 6], [7, 8]])
        c = tf.matmul(a, b)
        print_success("TensorFlow tensor operations successful")
        tf_success = True
    except Exception as e:
        print_error(f"TensorFlow test failed: {e}")

    # Test PyTorch
    try:
        import torch
        print_success(f"PyTorch version: {torch.__version__}")

        # Simple tensor operation
        x = torch.randn(3, 3)
        y = torch.randn(3, 3)
        z = torch.matmul(x, y)
        print_success("PyTorch tensor operations successful")
        torch_success = True
    except Exception as e:
        print_error(f"PyTorch test failed: {e}")

    return tf_success or torch_success  # At least one should work

def test_flask_app():
    """Test Flask web application"""
    print_header("Testing Flask Web Application")

    try:
        from flask import Flask

        app = Flask(__name__)

        @app.route('/')
        def hello():
            return "Hello from Flask test!"

        print_success("Flask app creation successful")
        print_success("Route definition successful")

        return True
    except Exception as e:
        print_error(f"Flask test failed: {e}")
        return False

def test_project_structure():
    """Test project structure and file existence"""
    print_header("Testing Project Structure")

    required_files = [
        'requirements.txt',
        'setup_python_windows.ps1',
        'setup_python_windows.bat',
        'SETUP_GUIDE.md',
        'README_Windows_Dev.md',
        'dev_env_requirements.txt'
    ]

    required_dirs = [
        'dev_env',
        'projects/active',
        'projects/archive',
        'projects/experiments',
        'projects/templates/python',
        'scripts'
    ]

    files_success = 0
    dirs_success = 0

    # Check files
    for file in required_files:
        if Path(file).exists():
            print_success(f"File exists: {file}")
            files_success += 1
        else:
            print_error(f"File missing: {file}")

    # Check directories
    for dir_path in required_dirs:
        if Path(dir_path).exists():
            print_success(f"Directory exists: {dir_path}")
            dirs_success += 1
        else:
            print_error(f"Directory missing: {dir_path}")

    print(f"\nFiles: {files_success}/{len(required_files)} found")
    print(f"Directories: {dirs_success}/{len(required_dirs)} found")

    return files_success == len(required_files) and dirs_success == len(required_dirs)

def test_jupyter_kernel():
    """Test Jupyter kernel availability"""
    print_header("Testing Jupyter Kernel")

    try:
        import subprocess
        result = subprocess.run(['jupyter', 'kernelspec', 'list'],
                              capture_output=True, text=True, timeout=10)

        if 'dev_env' in result.stdout:
            print_success("Jupyter kernel 'dev_env' found")
            return True
        else:
            print_warning("Jupyter kernel 'dev_env' not found")
            print("Available kernels:")
            print(result.stdout)
            return False
    except Exception as e:
        print_error(f"Jupyter kernel test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Python Development Environment Test Suite")
    print(f"Platform: {platform.system()} {platform.release()}")
    print(f"Python: {sys.version}")
    print(f"Current directory: {Path.cwd()}")
    print("=" * 60)

    tests = [
        ("Basic Package Imports", test_basic_imports),
        ("CV/AI Package Imports", test_cv_ai_imports),
        ("Web Development Imports", test_web_dev_imports),
        ("Development Tools", test_dev_tools),
        ("NumPy Functionality", test_numpy_functionality),
        ("OpenCV Functionality", test_opencv_functionality),
        ("ML Framework Functionality", test_tensorflow_pytorch),
        ("Flask Application", test_flask_app),
        ("Project Structure", test_project_structure),
        ("Jupyter Kernel", test_jupyter_kernel)
    ]

    results = []
    start_time = time.time()

    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print_error(f"{test_name} crashed: {e}")
            results.append((test_name, False))

    # Summary
    end_time = time.time()
    duration = end_time - start_time

    print_header("TEST SUMMARY")
    print(f"Total execution time: {duration:.2f} seconds")

    passed = 0
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
        if result:
            passed += 1

    print(f"\nOverall Score: {passed}/{total} tests passed ({passed/total*100:.1f}%)")

    if passed == total:
        print("\n🎉 ALL TESTS PASSED! Your environment is fully functional.")
        print("You can now start developing with confidence!")
        return 0
    elif passed >= total * 0.8:
        print("\n👍 MOST TESTS PASSED! Your environment is mostly functional.")
        print("Check the failed tests above for minor issues.")
        return 1
    else:
        print("\n⚠️  SOME TESTS FAILED! Check the output above for issues.")
        print("You may need to reinstall some packages or fix configuration.")
        return 2

if __name__ == "__main__":
    sys.exit(main())
