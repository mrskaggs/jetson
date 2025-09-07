#!/usr/bin/env python3
"""
Ollama Integration Script for Object Detection
Demonstrates how to use Ollama with the object detection API
"""

import requests
import json
import time
import subprocess
import sys

class OllamaObjectDetection:
    def __init__(self, api_base="http://localhost:5000", ollama_base="http://localhost:11434"):
        self.api_base = api_base
        self.ollama_base = ollama_base

    def check_api_health(self):
        """Check if the object detection API is running"""
        try:
            response = requests.get(f"{self.api_base}/health")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"API health check failed: {e}")
            return None

    def start_detection(self):
        """Start object detection"""
        try:
            response = requests.post(f"{self.api_base}/start")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Failed to start detection: {e}")
            return None

    def stop_detection(self):
        """Stop object detection"""
        try:
            response = requests.post(f"{self.api_base}/stop")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Failed to stop detection: {e}")
            return None

    def get_detection_summary(self):
        """Get current detection summary"""
        try:
            response = requests.get(f"{self.api_base}/summary")
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Failed to get detection summary: {e}")
            return None

    def query_ollama_with_context(self, user_prompt, model="llama2"):
        """Send a prompt to Ollama with object detection context"""
        try:
            # Get current detection context
            context_response = requests.post(
                f"{self.api_base}/ollama/prompt",
                json={"prompt": user_prompt}
            )

            if context_response.status_code != 200:
                print(f"Failed to get context: {context_response.status_code}")
                return None

            context_data = context_response.json()
            enhanced_prompt = context_data["enhanced_prompt"]

            # Send to Ollama
            ollama_response = requests.post(
                f"{self.ollama_base}/api/generate",
                json={
                    "model": model,
                    "prompt": enhanced_prompt,
                    "stream": False
                }
            )

            if ollama_response.status_code == 200:
                return ollama_response.json()["response"]
            else:
                print(f"Ollama request failed: {ollama_response.status_code}")
                return None

        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
            return None

    def get_scene_analysis(self, model="llama2"):
        """Get comprehensive scene analysis from Ollama"""
        try:
            # Get scene analysis prompt
            scene_response = requests.get(f"{self.api_base}/ollama/scene_analysis")

            if scene_response.status_code != 200:
                print(f"Failed to get scene analysis: {scene_response.status_code}")
                return None

            scene_data = scene_response.json()
            analysis_prompt = scene_data["scene_analysis_prompt"]

            # Send to Ollama
            ollama_response = requests.post(
                f"{self.ollama_base}/api/generate",
                json={
                    "model": model,
                    "prompt": analysis_prompt,
                    "stream": False
                }
            )

            if ollama_response.status_code == 200:
                return ollama_response.json()["response"]
            else:
                print(f"Ollama request failed: {ollama_response.status_code}")
                return None

        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
            return None

    def interactive_mode(self):
        """Run interactive mode for testing"""
        print("🤖 Ollama + Object Detection Interactive Mode")
        print("=" * 50)
        print("Commands:")
        print("  start    - Start object detection")
        print("  stop     - Stop object detection")
        print("  status   - Show detection status")
        print("  summary  - Show detection summary")
        print("  ask      - Ask a question with detection context")
        print("  quit     - Exit")
        print("")

        while True:
            try:
                command = input("Enter command: ").strip().lower()

                if command == "start":
                    result = self.start_detection()
                    if result:
                        print(f"✅ {result['message']}")
                    else:
                        print("❌ Failed to start detection")

                elif command == "stop":
                    result = self.stop_detection()
                    if result:
                        print(f"✅ {result['message']}")
                    else:
                        print("❌ Failed to stop detection")

                elif command == "status":
                    health = self.check_api_health()
                    if health:
                        print(f"API Status: {health['status']}")
                        print(f"Detection Running: {health['detection_running']}")
                        print(f"Detector Initialized: {health['detector_initialized']}")
                    else:
                        print("❌ Unable to get status")

                elif command == "summary":
                    summary = self.get_detection_summary()
                    if summary:
                        print(f"📊 Detection Summary (Total: {summary['total_objects']})")
                        for obj in summary['objects']:
                            print(f"  - {obj['class']}: {obj['count']} (avg depth: {obj['average_depth']:.2f}m)")
                    else:
                        print("❌ No detection data available")

                elif command == "ask":
                    question = input("What would you like to ask? ")
                    if question.strip():
                        print("🤔 Thinking with object detection context...")
                        response = self.query_ollama_with_context(question)
                        if response:
                            print("\n🧠 Ollama Response:")
                            print(response)
                        else:
                            print("❌ Failed to get response from Ollama")
                    print("")

                elif command == "quit":
                    print("👋 Goodbye!")
                    break

                else:
                    print("❓ Unknown command. Type 'help' for available commands.")

            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"❌ Error: {e}")

def main():
    """Main function"""
    print("🚀 Starting Ollama Object Detection Integration...")

    # Check if API is running
    integration = OllamaObjectDetection()

    health = integration.check_api_health()
    if not health:
        print("❌ Object Detection API is not running!")
        print("Please start the API server first:")
        print("  python3 object_detection_api.py")
        sys.exit(1)

    print("✅ Object Detection API is running")

    # Check if Ollama is running
    try:
        response = requests.get("http://localhost:11434/api/tags")
        if response.status_code != 200:
            print("❌ Ollama is not running!")
            print("Please start Ollama first:")
            print("  ollama serve")
            sys.exit(1)
    except:
        print("❌ Cannot connect to Ollama!")
        print("Please start Ollama first:")
        print("  ollama serve")
        sys.exit(1)

    print("✅ Ollama is running")
    print("")

    # Start interactive mode
    integration.interactive_mode()

if __name__ == "__main__":
    main()
