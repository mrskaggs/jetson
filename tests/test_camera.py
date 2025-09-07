#!/usr/bin/env python3
"""
Test script for Intel RealSense D435 camera connection and basic functionality
"""

import cv2
import numpy as np
import pyrealsense2 as rs
import sys
from datetime import datetime

def test_camera_connection():
    """Test basic camera connection and streaming"""
    print("=== Testing RealSense D435 Camera Connection ===")

    try:
        # Create a context object
        ctx = rs.context()

        # Get connected devices
        devices = ctx.query_devices()
        print(f"Found {len(devices)} RealSense device(s)")

        if len(devices) == 0:
            print("❌ No RealSense cameras detected!")
            print("Please check:")
            print("  - Camera is properly connected via USB")
            print("  - Camera has power (if external power is required)")
            print("  - USB cable is not damaged")
            return False

        # Print device information
        for i, device in enumerate(devices):
            print(f"\nDevice {i+1}:")
            print(f"  Name: {device.get_info(rs.camera_info.name)}")
            print(f"  Serial: {device.get_info(rs.camera_info.serial_number)}")
            print(f"  Firmware: {device.get_info(rs.camera_info.firmware_version)}")
            print(f"  USB Type: {device.get_info(rs.camera_info.usb_type_descriptor)}")

        return True

    except Exception as e:
        print(f"❌ Error testing camera connection: {e}")
        return False

def test_camera_streaming():
    """Test camera streaming capabilities"""
    print("\n=== Testing Camera Streaming ===")

    try:
        # Configure streams
        pipeline = rs.pipeline()
        config = rs.config()

        # Enable color and depth streams
        config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)
        config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)

        # Start streaming
        print("Starting camera streams...")
        pipeline.start(config)

        # Wait for frames
        print("Waiting for frames...")
        frames = pipeline.wait_for_frames(timeout_ms=5000)

        # Get frames
        color_frame = frames.get_color_frame()
        depth_frame = frames.get_depth_frame()

        if not color_frame:
            print("❌ No color frame received!")
            return False

        if not depth_frame:
            print("❌ No depth frame received!")
            return False

        # Convert to numpy arrays
        color_image = np.asanyarray(color_frame.get_data())
        depth_image = np.asanyarray(depth_frame.get_data())

        print("✅ Successfully received frames!")
        print(f"  Color frame shape: {color_image.shape}")
        print(f"  Depth frame shape: {depth_image.shape}")

        # Test depth measurement
        height, width = depth_image.shape
        center_depth = depth_frame.get_distance(width//2, height//2)
        print(f"  Center depth: {center_depth:.2f}m")
        # Stop streaming
        pipeline.stop()
        print("✅ Camera streaming test completed successfully!")
        return True

    except Exception as e:
        print(f"❌ Error testing camera streaming: {e}")
        return False

def test_opencv_cuda():
    """Test OpenCV CUDA functionality"""
    print("\n=== Testing OpenCV CUDA Support ===")

    try:
        # Check CUDA device count
        cuda_count = cv2.cuda.getCudaEnabledDeviceCount()
        print(f"CUDA enabled devices: {cuda_count}")

        if cuda_count > 0:
            print("✅ CUDA support detected in OpenCV")
            return True
        else:
            print("⚠️  No CUDA devices detected - using CPU fallback")
            return True  # Not a failure, just using CPU

    except Exception as e:
        print(f"❌ Error testing OpenCV CUDA: {e}")
        return False

def test_model_loading():
    """Test loading the object detection model"""
    print("\n=== Testing Model Loading ===")

    try:
        import os

        model_dir = '../models'
        prototxt_path = f'{model_dir}/MobileNetSSD_deploy.prototxt'
        caffemodel_path = f'{model_dir}/MobileNetSSD_deploy.caffemodel'

        if not os.path.exists(prototxt_path):
            print(f"❌ Prototxt file not found: {prototxt_path}")
            print("Please run setup_jetson.sh to download model files")
            return False

        if not os.path.exists(caffemodel_path):
            print(f"❌ Caffemodel file not found: {caffemodel_path}")
            print("Please run setup_jetson.sh to download model files")
            return False

        # Try to load the model
        net = cv2.dnn.readNetFromCaffe(prototxt_path, caffemodel_path)

        # Try to set CUDA backend
        try:
            net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
            net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
            print("✅ Model loaded with CUDA acceleration")
        except:
            print("⚠️  CUDA acceleration not available - using CPU")
            net.setPreferableBackend(cv2.dnn.DNN_BACKEND_DEFAULT)
            net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)

        print("✅ Model loading test completed successfully!")
        return True

    except Exception as e:
        print(f"❌ Error testing model loading: {e}")
        return False

def main():
    """Run all tests"""
    print(f"RealSense Camera Test - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)

    tests = [
        ("Camera Connection", test_camera_connection),
        ("OpenCV CUDA Support", test_opencv_cuda),
        ("Model Loading", test_model_loading),
        ("Camera Streaming", test_camera_streaming),
    ]

    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} failed with exception: {e}")
            results.append((test_name, False))

    # Summary
    print("\n" + "=" * 50)
    print("TEST SUMMARY")
    print("=" * 50)

    passed = 0
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
        if result:
            passed += 1

    print(f"\nPassed: {passed}/{total}")

    if passed == total:
        print("🎉 All tests passed! Ready to run object detection.")
        return 0
    else:
        print("⚠️  Some tests failed. Please check the output above for details.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
