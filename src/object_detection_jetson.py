#!/usr/bin/env python3
"""
Object Detection with Intel RealSense D435 on NVIDIA Jetson Orin Nano Super
"""

import cv2
import numpy as np
import pyrealsense2 as rs
import time
from datetime import datetime

class ObjectDetector:
    def __init__(self):
        # Initialize RealSense pipeline
        self.pipeline = rs.pipeline()
        self.config = rs.config()

        # Configure streams
        self.config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)
        self.config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)

        # Start streaming
        self.pipeline.start(self.config)

        # Load object detection model
        self.load_model()

        print("Object Detector initialized successfully")

    def load_model(self):
        """Load pre-trained object detection model"""
        # Using MobileNet SSD for object detection
        model_dir = '../models'
        prototxt_path = f'{model_dir}/MobileNetSSD_deploy.prototxt'
        caffemodel_path = f'{model_dir}/MobileNetSSD_deploy.caffemodel'

        # Check if model files exist
        import os
        if not os.path.exists(prototxt_path) or not os.path.exists(caffemodel_path):
            raise FileNotFoundError(
                f"Model files not found in {model_dir}/. "
                "Please run setup_jetson.sh first to download the model files."
            )

        self.net = cv2.dnn.readNetFromCaffe(prototxt_path, caffemodel_path)

        # Enable CUDA acceleration for Jetson
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)

        # COCO class labels
        self.classes = [
            "background", "aeroplane", "bicycle", "bird", "boat",
            "bottle", "bus", "car", "cat", "chair", "cow", "diningtable",
            "dog", "horse", "motorbike", "person", "pottedplant", "sheep",
            "sofa", "train", "tvmonitor"
        ]

    def detect_objects(self, frame):
        """Detect objects in the given frame"""
        blob = cv2.dnn.blobFromImage(frame, 0.007843, (300, 300), 127.5)
        self.net.setInput(blob)
        detections = self.net.forward()

        objects = []
        (h, w) = frame.shape[:2]

        for i in range(detections.shape[2]):
            confidence = detections[0, 0, i, 2]

            if confidence > 0.5:  # Confidence threshold
                idx = int(detections[0, 0, i, 1])
                box = detections[0, 0, i, 3:7] * np.array([w, h, w, h])
                (startX, startY, endX, endY) = box.astype("int")

                objects.append({
                    'class': self.classes[idx],
                    'confidence': confidence,
                    'bbox': (startX, startY, endX, endY)
                })

        return objects

    def get_depth_at_point(self, depth_frame, x, y):
        """Get depth value at specific point"""
        depth = depth_frame.get_distance(x, y)
        return depth

    def draw_detections(self, frame, objects, depth_frame):
        """Draw bounding boxes and labels on frame"""
        for obj in objects:
            (startX, startY, endX, endY) = obj['bbox']
            label = f"{obj['class']}: {obj['confidence']:.2f}"

            # Get depth at center of bounding box
            center_x = (startX + endX) // 2
            center_y = (startY + endY) // 2
            depth = self.get_depth_at_point(depth_frame, center_x, center_y)

            # Draw bounding box
            cv2.rectangle(frame, (startX, startY), (endX, endY), (0, 255, 0), 2)

            # Draw label with depth
            label_with_depth = f"{label} ({depth:.2f}m)"
            cv2.putText(frame, label_with_depth, (startX, startY - 10),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)

        return frame

    def run(self):
        """Main detection loop"""
        try:
            while True:
                # Wait for frames
                frames = self.pipeline.wait_for_frames()
                color_frame = frames.get_color_frame()
                depth_frame = frames.get_depth_frame()

                if not color_frame or not depth_frame:
                    continue

                # Convert to numpy arrays
                color_image = np.asanyarray(color_frame.get_data())
                depth_image = np.asanyarray(depth_frame.get_data())

                # Detect objects
                objects = self.detect_objects(color_image)

                # Draw detections
                result_frame = self.draw_detections(color_image, objects, depth_frame)

                # Display frame
                cv2.imshow('Object Detection - RealSense D435', result_frame)

                # Print detection info
                if objects:
                    timestamp = datetime.now().strftime("%H:%M:%S")
                    print(f"[{timestamp}] Detected {len(objects)} object(s):")
                    for obj in objects:
                        print(f"  - {obj['class']} (confidence: {obj['confidence']:.2f})")

                # Exit on 'q' key
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

        finally:
            # Stop streaming
            self.pipeline.stop()
            cv2.destroyAllWindows()

def main():
    print("Starting Object Detection with RealSense D435 on Jetson Orin Nano")
    detector = ObjectDetector()
    detector.run()

if __name__ == "__main__":
    main()
