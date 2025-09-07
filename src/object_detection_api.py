#!/usr/bin/env python3
"""
Flask API server for Object Detection with RealSense D435
Provides REST endpoints for Ollama integration
"""

from flask import Flask, jsonify, request, Response
import threading
import time
import cv2
import numpy as np
import pyrealsense2 as rs
from datetime import datetime
import json
import os

app = Flask(__name__)

class ObjectDetectionAPI:
    def __init__(self):
        self.detector = None
        self.is_running = False
        self.current_detections = []
        self.detection_thread = None
        self.lock = threading.Lock()

    def initialize_detector(self):
        """Initialize the object detector"""
        try:
            # Import here to avoid circular imports
            from object_detection_jetson import ObjectDetector
            self.detector = ObjectDetector()
            return True
        except Exception as e:
            print(f"Failed to initialize detector: {e}")
            return False

    def start_detection(self):
        """Start object detection in background thread"""
        if self.is_running:
            return {"status": "already_running", "message": "Detection already running"}

        if not self.detector:
            if not self.initialize_detector():
                return {"status": "error", "message": "Failed to initialize detector"}

        self.is_running = True
        self.detection_thread = threading.Thread(target=self._detection_loop)
        self.detection_thread.daemon = True
        self.detection_thread.start()

        return {"status": "started", "message": "Object detection started"}

    def stop_detection(self):
        """Stop object detection"""
        self.is_running = False
        if self.detection_thread:
            self.detection_thread.join(timeout=2.0)
        return {"status": "stopped", "message": "Object detection stopped"}

    def _detection_loop(self):
        """Main detection loop running in background"""
        try:
            while self.is_running:
                if not self.detector:
                    break

                # Get frames
                frames = self.detector.pipeline.wait_for_frames()
                color_frame = frames.get_color_frame()
                depth_frame = frames.get_depth_frame()

                if not color_frame or not depth_frame:
                    continue

                # Convert to numpy arrays
                color_image = np.asanyarray(color_frame.get_data())

                # Detect objects
                objects = self.detector.detect_objects(color_image)

                # Update current detections with depth info
                detections = []
                for obj in objects:
                    (startX, startY, endX, endY) = obj['bbox']
                    center_x = (startX + endX) // 2
                    center_y = (startY + endY) // 2
                    depth = self.detector.get_depth_at_point(depth_frame, center_x, center_y)

                    detections.append({
                        'class': obj['class'],
                        'confidence': float(obj['confidence']),
                        'bbox': obj['bbox'],
                        'depth': float(depth),
                        'timestamp': datetime.now().isoformat()
                    })

                with self.lock:
                    self.current_detections = detections

                # Small delay to prevent excessive CPU usage
                time.sleep(0.1)

        except Exception as e:
            print(f"Detection loop error: {e}")
            self.is_running = False

    def get_current_detections(self):
        """Get current detection results"""
        with self.lock:
            return self.current_detections.copy()

    def get_detection_summary(self):
        """Get summary of current detections"""
        detections = self.get_current_detections()

        if not detections:
            return {
                "total_objects": 0,
                "objects": [],
                "timestamp": datetime.now().isoformat()
            }

        # Group by class
        class_counts = {}
        for detection in detections:
            obj_class = detection['class']
            if obj_class not in class_counts:
                class_counts[obj_class] = 0
            class_counts[obj_class] += 1

        return {
            "total_objects": len(detections),
            "objects": [
                {
                    "class": obj_class,
                    "count": count,
                    "average_depth": np.mean([
                        d['depth'] for d in detections if d['class'] == obj_class
                    ])
                }
                for obj_class, count in class_counts.items()
            ],
            "timestamp": datetime.now().isoformat()
        }

# Global API instance
api = ObjectDetectionAPI()

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "detector_initialized": api.detector is not None,
        "detection_running": api.is_running
    })

@app.route('/start', methods=['POST'])
def start_detection():
    """Start object detection"""
    result = api.start_detection()
    return jsonify(result)

@app.route('/stop', methods=['POST'])
def stop_detection():
    """Stop object detection"""
    result = api.stop_detection()
    return jsonify(result)

@app.route('/detections', methods=['GET'])
def get_detections():
    """Get current detections"""
    detections = api.get_current_detections()
    return jsonify({
        "detections": detections,
        "count": len(detections)
    })

@app.route('/summary', methods=['GET'])
def get_summary():
    """Get detection summary"""
    summary = api.get_detection_summary()
    return jsonify(summary)

@app.route('/query', methods=['GET'])
def query_objects():
    """Query specific objects"""
    obj_class = request.args.get('class')
    min_confidence = request.args.get('min_confidence', 0.5, type=float)
    max_depth = request.args.get('max_depth', type=float)

    detections = api.get_current_detections()
    filtered = []

    for detection in detections:
        if obj_class and detection['class'] != obj_class:
            continue
        if detection['confidence'] < min_confidence:
            continue
        if max_depth is not None and detection['depth'] > max_depth:
            continue
        filtered.append(detection)

    return jsonify({
        "query": {
            "class": obj_class,
            "min_confidence": min_confidence,
            "max_depth": max_depth
        },
        "results": filtered,
        "count": len(filtered)
    })

@app.route('/stream', methods=['GET'])
def stream_detections():
    """Server-sent events stream of detections"""
    def generate():
        while True:
            detections = api.get_current_detections()
            data = {
                "detections": detections,
                "count": len(detections),
                "timestamp": datetime.now().isoformat()
            }
            yield f"data: {json.dumps(data)}\n\n"
            time.sleep(0.5)  # Update every 500ms

    return Response(generate(), mimetype='text/event-stream')

@app.route('/ollama/prompt', methods=['POST'])
def ollama_prompt():
    """Endpoint for Ollama to send prompts and get object detection context"""
    data = request.get_json()

    if not data or 'prompt' not in data:
        return jsonify({"error": "Missing prompt in request"}), 400

    prompt = data['prompt']
    detections = api.get_current_detections()
    summary = api.get_detection_summary()

    # Create comprehensive context from current detections
    context = f"""
Current Scene Analysis from RealSense D435 Camera:
- Total objects detected: {summary['total_objects']}
- Timestamp: {summary['timestamp']}
- Camera: Intel RealSense D435 (RGB + Depth sensor)
- Detection Model: MobileNet SSD (trained on COCO dataset)

Detected Objects with Depth Information:
"""

    for obj in summary['objects']:
        context += f"- {obj['class']}: {obj['count']} detected (average depth: {obj['average_depth']:.2f}m)\n"

    if detections:
        context += "\nDetailed Object Locations:\n"
        for detection in detections:
            context += f"- {detection['class']} at {detection['depth']:.2f}m distance (confidence: {detection['confidence']:.2f})\n"

    # Enhanced prompt that leverages Ollama's broader knowledge
    enhanced_prompt = f"""
{context}

IMPORTANT: While the computer vision system can only detect objects from its trained COCO dataset (20 classes), you have much broader knowledge and can:

1. Infer the presence of objects not in the detection list based on context
2. Provide detailed descriptions of detected objects
3. Analyze the scene as a whole
4. Make educated guesses about what might be present
5. Answer questions about spatial relationships and scene understanding
6. Consider lighting, environment, and contextual clues

User Query: {prompt}

Please provide an intelligent, contextual response that goes beyond just listing detected objects. Use your knowledge to analyze the scene, infer additional details, and answer the user's question comprehensively.
"""

    return jsonify({
        "enhanced_prompt": enhanced_prompt,
        "detection_context": {
            "summary": summary,
            "detections": detections,
            "limitations": "Computer vision limited to 20 COCO classes",
            "ollama_capabilities": "Can infer additional objects and provide scene analysis"
        },
        "original_prompt": prompt
    })

@app.route('/ollama/scene_analysis', methods=['GET'])
def ollama_scene_analysis():
    """Get a comprehensive scene analysis prompt for Ollama"""
    detections = api.get_current_detections()
    summary = api.get_detection_summary()

    scene_prompt = f"""
Analyze this scene from a RealSense D435 camera feed:

DETECTED OBJECTS:
- Total: {summary['total_objects']} objects
"""

    for obj in summary['objects']:
        scene_prompt += f"- {obj['class']}: {obj['count']} instances (avg distance: {obj['average_depth']:.2f}m)\n"

    if detections:
        scene_prompt += "\nSPATIAL INFORMATION:\n"
        for detection in detections:
            scene_prompt += f"- {detection['class']} located at {detection['depth']:.2f}m\n"

    scene_prompt += """

Based on this data and your extensive knowledge, please provide:
1. A description of what you think is happening in this scene
2. What objects might be present that the detection system couldn't identify
3. Spatial relationships between objects
4. Possible activities or contexts suggested by the detected objects
5. Any safety concerns or notable observations

Be creative and use contextual reasoning - don't limit yourself to just the detected objects!
"""

    return jsonify({
        "scene_analysis_prompt": scene_prompt,
        "detection_data": {
            "summary": summary,
            "detections": detections
        }
    })

if __name__ == '__main__':
    print("Starting Object Detection API Server...")
    print("API Endpoints:")
    print("  GET  /health          - Health check")
    print("  POST /start           - Start detection")
    print("  POST /stop            - Stop detection")
    print("  GET  /detections      - Get current detections")
    print("  GET  /summary         - Get detection summary")
    print("  GET  /query           - Query specific objects")
    print("  GET  /stream          - SSE stream of detections")
    print("  POST /ollama/prompt   - Enhanced prompt for Ollama")
    print("")
    print("Server running on http://localhost:5000")

    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
