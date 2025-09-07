# Object Detection with Intel RealSense D435 on NVIDIA Jetson Orin Nano Super

This project implements real-time object detection using an Intel RealSense D435 depth camera on an NVIDIA Jetson Orin Nano Super Developer Kit. The system combines computer vision with depth sensing to detect objects and provide distance information.

## Features

- **Real-time object detection** using MobileNet SSD with COCO dataset classes
- **Depth sensing integration** showing distance to detected objects
- **CUDA acceleration** optimized for NVIDIA Jetson platform
- **Live video streaming** with bounding boxes and labels
- **Console logging** of detection results with timestamps
- **REST API** for programmatic access and integration
- **Ollama integration** for AI-powered object analysis and interaction

## Hardware Requirements

- NVIDIA Jetson Orin Nano Super Developer Kit
- Intel RealSense Depth Camera D435
- USB connection between Jetson and RealSense camera

## Software Requirements

- Ubuntu 20.04 (or JetPack SDK)
- Python 3.8+
- OpenCV with CUDA support
- Intel RealSense SDK 2.0
- CUDA Toolkit

## Installation

1. **Clone or copy the project files to your Jetson device**

2. **Make the setup script executable:**
   ```bash
   chmod +x setup_jetson.sh
   ```

3. **Run the setup script:**
   ```bash
   ./setup_jetson.sh
   ```

   This script will:
   - Update system packages
   - Install OpenCV with CUDA support
   - Install Intel RealSense SDK
   - Install Python dependencies
   - Download pre-trained model files
   - Configure udev rules for camera access

4. **Connect your RealSense D435 camera** to the Jetson via USB

## Usage

1. **Navigate to the project directory:**
   ```bash
   cd /path/to/your/project
   ```

2. **Test the setup (optional but recommended):**
   ```bash
   python3 test_camera.py
   ```

3. **Run the object detection:**
   ```bash
   python3 object_detection_jetson.py
   ```

3. **Controls:**
   - Press `q` to quit the application
   - The video feed will display in a window
   - Detection results are printed to the console

## Output

The application provides:

- **Visual output:** Live video feed with bounding boxes around detected objects
- **Labels:** Object class and confidence score
- **Depth information:** Distance to each detected object in meters
- **Console output:** Timestamped detection logs

### Example Console Output:
```
[14:23:15] Detected 2 object(s):
  - person (confidence: 0.87)
  - chair (confidence: 0.72)
```

## API Server and Ollama Integration

The system includes a REST API server and Ollama integration for advanced AI-powered object analysis.

### Starting the API Server

Run the API server in a separate terminal:

```bash
python3 object_detection_api.py
```

The API server will start on `http://localhost:5000` and provide the following endpoints:

- `GET /health` - Health check and system status
- `POST /start` - Start object detection
- `POST /stop` - Stop object detection
- `GET /detections` - Get current detections
- `GET /summary` - Get detection summary
- `GET /query?class=person&min_confidence=0.5` - Query specific objects
- `GET /stream` - Server-sent events stream of detections
- `POST /ollama/prompt` - Enhanced prompt for Ollama with detection context

### Ollama Integration

The system integrates with Ollama to provide AI-powered analysis that **goes beyond the detection limitations**. While the computer vision system is limited to 20 COCO classes, Ollama can:

- **Infer additional objects** not detected by the model
- **Analyze scene context** and relationships
- **Provide detailed descriptions** of detected objects
- **Answer complex questions** about the environment
- **Make contextual inferences** about activities and situations

1. **Start the API server** (as shown above)
2. **Start Ollama service:**
   ```bash
   ollama serve
   ```
3. **Run the integration script:**
   ```bash
   python3 ollama_integration.py
   ```

### Enhanced Ollama Capabilities

The integration provides:
- **Context-aware prompts** that include current detection data
- **Interactive mode** for testing and exploration
- **Scene analysis** that infers objects beyond detection limits
- **Intelligent question answering** about the environment

### Example Ollama Integration

```python
from ollama_integration import OllamaObjectDetection

# Initialize integration
od = OllamaObjectDetection()

# Start detection
od.start_detection()

# Ask intelligent questions that go beyond detection limits
response = od.query_ollama_with_context(
    "What do you think is happening in this room based on the detected objects?"
)
print(response)

# Get comprehensive scene analysis
scene_analysis = od.get_scene_analysis()
print(scene_analysis)
```

### Sample Questions for Ollama

**Basic Detection Queries:**
- "What objects are closest to the camera?"
- "How many people are in the scene?"

**Advanced Analysis (Beyond Detection Limits):**
- "What room do you think this is based on the objects?"
- "What activity might be happening here?"
- "Are there any objects you would expect to see that aren't detected?"
- "Describe the lighting and environment conditions"
- "What safety concerns might there be in this scene?"

## Configuration

### Detection Parameters

You can modify detection parameters in the `ObjectDetector` class:

- **Confidence threshold:** Change `0.5` in `detect_objects()` method (line ~60)
- **Input resolution:** Modify stream configuration in `__init__()` (lines ~18-19)
- **Frame rate:** Adjust the 30 FPS setting in stream configuration

### Model Selection

The current implementation uses MobileNet SSD. To use a different model:

1. Update the `load_model()` method
2. Download appropriate model files
3. Modify the `detect_objects()` method for the new model's input requirements

## Performance Optimization

The code is optimized for Jetson with:

- CUDA backend for neural network inference
- GPU-accelerated image processing
- Efficient memory management
- Asynchronous frame capture

### Performance Tips

- Use higher confidence thresholds for better accuracy
- Reduce input resolution for faster processing
- Consider using TensorRT for further optimization

## Troubleshooting

### Camera Not Detected
```bash
# Check if camera is connected
rs-enumerate-devices

# Restart camera service
sudo systemctl restart librealsense2

# Check USB connection
lsusb | grep Intel
```

### CUDA Errors
```bash
# Verify CUDA installation
nvcc --version

# Check GPU status
nvidia-smi
```

### Import Errors
```bash
# Reinstall dependencies
pip3 install -r requirements.txt

# Verify OpenCV CUDA support
python3 -c "import cv2; print(cv2.cuda.getCudaEnabledDeviceCount())"
```

## Project Structure

```
.
├── object_detection_jetson.py    # Main application
├── object_detection_api.py       # REST API server for integrations
├── ollama_integration.py         # Ollama integration and interactive mode
├── demo_ollama_capabilities.py   # Demo of enhanced Ollama capabilities
├── test_camera.py                # Camera and system testing script
├── requirements.txt               # Python dependencies
├── setup_jetson.sh               # Installation script
├── models/                       # Pre-trained model files
│   ├── MobileNetSSD_deploy.prototxt
│   └── MobileNetSSD_deploy.caffemodel
├── data/                         # Data directory (for future use)
└── README.md                     # This file
```

## Supported Object Classes

The system can detect the following COCO dataset classes:
- person, bicycle, car, motorbike, aeroplane, bus, train, truck
- boat, traffic light, fire hydrant, stop sign, parking meter, bench
- bird, cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe
- backpack, umbrella, handbag, tie, suitcase, frisbee, skis, snowboard
- sports ball, kite, baseball bat, baseball glove, skateboard, surfboard
- tennis racket, bottle, wine glass, cup, fork, knife, spoon, bowl
- banana, apple, sandwich, orange, broccoli, carrot, hot dog, pizza
- donut, cake, chair, sofa, pottedplant, bed, diningtable, toilet
- tvmonitor, laptop, mouse, remote, keyboard, cell phone, microwave
- oven, toaster, sink, refrigerator, book, clock, vase, scissors
- teddy bear, hair drier, toothbrush

## Future Enhancements

- [ ] Add support for custom trained models
- [ ] Implement object tracking across frames
- [ ] Add 3D point cloud visualization
- [ ] Integrate with ROS (Robot Operating System)
- [ ] Add recording functionality
- [ ] Implement multi-camera support

## License

This project is open-source. Please check individual component licenses for OpenCV, Intel RealSense SDK, and MobileNet SSD.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the project.

## References

- [Intel RealSense SDK Documentation](https://github.com/IntelRealSense/librealsense)
- [OpenCV Documentation](https://docs.opencv.org/)
- [MobileNet SSD Paper](https://arxiv.org/abs/1704.04861)
- [NVIDIA Jetson Documentation](https://docs.nvidia.com/jetson/)
