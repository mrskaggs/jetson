#!/usr/bin/env python3
"""
Demonstration of Ollama's enhanced capabilities beyond basic object detection
Shows how Ollama can infer objects and provide intelligent analysis
"""

import requests
import time
import sys

def demonstrate_capabilities():
    """Demonstrate Ollama's capabilities beyond detection limits"""

    print("🎯 Ollama Enhanced Object Detection Demo")
    print("=" * 50)
    print()

    # Simulated detection data (what the computer vision system would see)
    mock_detections = {
        "total_objects": 3,
        "objects": [
            {"class": "person", "count": 1, "average_depth": 2.1},
            {"class": "chair", "count": 2, "average_depth": 1.8}
        ],
        "timestamp": "2025-01-07T11:14:38"
    }

    print("📊 What the Computer Vision System Detects:")
    print(f"   Total objects: {mock_detections['total_objects']}")
    for obj in mock_detections['objects']:
        print(f"   - {obj['class']}: {obj['count']} (avg depth: {obj['average_depth']:.1f}m)")
    print()

    print("🤖 What Ollama Can Infer and Analyze:")
    print("   (Based on the same detection data)")
    print()

    # Example prompts that show Ollama's enhanced capabilities
    example_scenarios = [
        {
            "scenario": "Office Environment Analysis",
            "prompt": "Based on detecting 1 person and 2 chairs, what type of room do you think this is and what activity might be happening?"
        },
        {
            "scenario": "Missing Object Inference",
            "prompt": "If I see a person sitting in a chair, what objects would you expect to see in this scene that aren't currently detected?"
        },
        {
            "scenario": "Contextual Understanding",
            "prompt": "Describe what you think is happening in this scene and suggest what the person might be doing."
        },
        {
            "scenario": "Safety Analysis",
            "prompt": "Based on the detected objects and their positions, are there any safety concerns you would identify?"
        }
    ]

    for i, scenario in enumerate(example_scenarios, 1):
        print(f"{i}. {scenario['scenario']}:")
        print(f"   Question: {scenario['prompt']}")
        print("   Ollama would analyze this and provide intelligent insights...")
        print()

    print("💡 Key Advantages of Ollama Integration:")
    print("   • Can identify objects beyond the 20 COCO classes")
    print("   • Provides contextual scene understanding")
    print("   • Makes inferences about activities and environments")
    print("   • Answers complex questions about spatial relationships")
    print("   • Considers lighting, context, and environmental factors")
    print("   • Provides safety analysis and recommendations")
    print()

    print("🔄 Comparison:")
    print("   Computer Vision: Limited to trained classes (person, chair, etc.)")
    print("   Ollama Enhanced: Can infer desks, computers, books, lighting,")
    print("                    activities, safety concerns, and much more!")
    print()

def test_real_integration():
    """Test with real API if available"""
    print("🧪 Testing Real Integration (if API is running)...")

    try:
        # Check if API is running
        health_response = requests.get("http://localhost:5000/health", timeout=2)

        if health_response.status_code == 200:
            print("✅ API is running - testing real integration")

            # Test scene analysis endpoint
            scene_response = requests.get("http://localhost:5000/ollama/scene_analysis", timeout=5)

            if scene_response.status_code == 200:
                scene_data = scene_response.json()
                print("✅ Scene analysis endpoint working")
                print("📝 Generated analysis prompt length:", len(scene_data.get('scene_analysis_prompt', '')))
            else:
                print("⚠️  Scene analysis endpoint not accessible")

        else:
            print("❌ API not running - start with: python3 object_detection_api.py")

    except requests.exceptions.RequestException:
        print("❌ Cannot connect to API - make sure it's running")

    print()

def main():
    """Main demonstration"""
    demonstrate_capabilities()
    test_real_integration()

    print("🚀 To experience the full integration:")
    print("   1. Start API: python3 object_detection_api.py")
    print("   2. Start Ollama: ollama serve")
    print("   3. Run interactive: python3 ollama_integration.py")
    print()
    print("Then try asking questions like:")
    print("   'What room is this?'")
    print("   'What might be happening here?'")
    print("   'Are there any safety concerns?'")

if __name__ == "__main__":
    main()
