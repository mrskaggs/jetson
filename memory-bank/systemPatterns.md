# System Patterns: Object Detection with RealSense D435 & Ollama Integration

## 🏗️ Architectural Patterns

### Core Architecture Pattern: Pipeline Processing
```
Input Stream → Preprocessing → Detection → Enhancement → Output
     ↓             ↓            ↓           ↓           ↓
RealSense   ┌─────────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
Camera ───▶ │ Frame       │ │ Object  │ │ AI       │ │ REST    │
           │ Processing  │ │ Detection│ │ Analysis │ │ API     │
           └─────────────┘ └─────────┘ └─────────┘ └─────────┘
```

**Key Characteristics:**
- **Modular Components**: Each stage is independent and replaceable
- **Data Flow**: Unidirectional flow with clear interfaces
- **Error Handling**: Graceful degradation at each stage
- **Performance Monitoring**: Metrics collection at pipeline boundaries

### Component Interaction Pattern: Observer Pattern
```
Detection Engine (Subject)
        │
        ├── API Server (Observer)
        ├── Ollama Integration (Observer)
        ├── Logging System (Observer)
        └── Performance Monitor (Observer)
```

**Benefits:**
- **Loose Coupling**: Components don't need to know about each other
- **Dynamic Registration**: Observers can be added/removed at runtime
- **Broadcast Communication**: Single event triggers multiple responses
- **Extensibility**: Easy to add new monitoring or processing components

## 🔄 Design Patterns

### Factory Pattern: Model Instantiation
```python
class ModelFactory:
    @staticmethod
    def create_detector(model_type: str) -> ObjectDetector:
        if model_type == "mobilenet":
            return MobileNetDetector()
        elif model_type == "yolo":
            return YOLODetector()
        else:
            raise ValueError(f"Unknown model type: {model_type}")
```

**Usage:**
- **Configuration-Driven**: Model selection via configuration files
- **Runtime Flexibility**: Switch models without code changes
- **Testing**: Easy mocking and testing of different models
- **Extensibility**: Add new models without modifying existing code

### Strategy Pattern: Processing Algorithms
```python
class ProcessingStrategy(ABC):
    @abstractmethod
    def process(self, frame: np.ndarray) -> DetectionResult:
        pass

class CUDAStrategy(ProcessingStrategy):
    def process(self, frame: np.ndarray) -> DetectionResult:
        # CUDA-accelerated processing
        return cuda_process_frame(frame)

class CPUFallbackStrategy(ProcessingStrategy):
    def process(self, frame: np.ndarray) -> DetectionResult:
        # CPU-based processing
        return cpu_process_frame(frame)
```

**Benefits:**
- **Algorithm Interchangeability**: Switch processing strategies at runtime
- **Performance Adaptation**: Automatic fallback based on hardware availability
- **Clean Interfaces**: Consistent API regardless of implementation
- **Testing**: Easy to test different processing approaches

### Singleton Pattern: Resource Management
```python
class CameraManager:
    _instance = None
    _camera = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def get_camera(self):
        if self._camera is None:
            self._camera = rs.pipeline()
        return self._camera
```

**Application:**
- **Resource Conservation**: Single camera instance across application
- **Thread Safety**: Controlled access to hardware resources
- **Lifecycle Management**: Proper initialization and cleanup
- **Global Access**: Consistent camera interface throughout application

## 📊 Data Flow Patterns

### Stream Processing Pattern
```
RealSense Stream → Frame Buffer → Processing Queue → Result Cache → API Response
       │                │                │               │            │
   30 FPS          Ring Buffer      Async Workers    LRU Cache   REST/WS API
```

**Characteristics:**
- **Asynchronous Processing**: Non-blocking frame processing
- **Buffering**: Handle frame rate variations and processing delays
- **Caching**: Reduce redundant computations
- **Load Balancing**: Distribute processing across available resources

### Configuration Management Pattern
```python
@dataclass
class AppConfig:
    camera_settings: CameraConfig
    detection_settings: DetectionConfig
    api_settings: APIConfig
    ollama_settings: OllamaConfig

    @classmethod
    def from_yaml(cls, path: str) -> 'AppConfig':
        with open(path) as f:
            data = yaml.safe_load(f)
        return cls(**data)
```

**Benefits:**
- **Centralized Configuration**: Single source of truth for all settings
- **Type Safety**: Dataclasses provide runtime type checking
- **Validation**: Configuration validation at startup
- **Environment Overrides**: Support for environment-specific settings

## 🔧 Implementation Patterns

### Error Handling Pattern: Circuit Breaker
```python
class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, recovery_timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = 'CLOSED'

    def call(self, func: Callable) -> Any:
        if self.state == 'OPEN':
            if self._should_attempt_reset():
                self.state = 'HALF_OPEN'
            else:
                raise CircuitBreakerError("Circuit is OPEN")

        try:
            result = func()
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e
```

**Application:**
- **Ollama Integration**: Handle network failures gracefully
- **Camera Connection**: Manage hardware disconnection scenarios
- **API Rate Limiting**: Prevent cascade failures
- **Resource Protection**: Safeguard against resource exhaustion

### Logging Pattern: Structured Logging
```python
import structlog

logger = structlog.get_logger()

def detect_objects(frame: np.ndarray) -> DetectionResult:
    logger.info("Starting object detection",
                frame_shape=frame.shape,
                timestamp=datetime.now().isoformat())

    try:
        detections = detector.detect(frame)
        logger.info("Detection completed",
                    detection_count=len(detections),
                    processing_time=time.process_time())

        return detections
    except Exception as e:
        logger.error("Detection failed",
                     error=str(e),
                     frame_shape=frame.shape)
        raise
```

**Benefits:**
- **Structured Data**: Consistent log format with searchable fields
- **Performance Monitoring**: Built-in timing and metrics
- **Debugging**: Rich context for troubleshooting
- **Analytics**: Log data can be analyzed for insights

## 🌐 Communication Patterns

### REST API Pattern: Resource-Based Design
```
/api/v1/
├── /health          # System health check
├── /detections      # Current detection results
├── /summary         # Detection statistics
├── /query           # Filtered detection queries
├── /stream          # Server-sent events stream
└── /ollama/prompt   # AI-enhanced prompts
```

**Principles:**
- **Resource Identification**: Clear, hierarchical resource naming
- **HTTP Methods**: Proper use of GET, POST, PUT, DELETE
- **Status Codes**: Meaningful HTTP status code responses
- **Content Negotiation**: Support for JSON, XML, and other formats

### WebSocket Pattern: Real-time Communication
```javascript
// Client-side WebSocket connection
const ws = new WebSocket('ws://localhost:5000/stream');

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    updateDetectionDisplay(data.detections);
};

ws.onclose = () => {
    console.log('Detection stream closed');
    // Implement reconnection logic
};
```

**Use Cases:**
- **Live Detection Feed**: Real-time detection updates
- **Performance Monitoring**: Live metrics and statistics
- **System Alerts**: Immediate notification of issues
- **Interactive Control**: Remote system control and configuration

## 🔒 Security Patterns

### Input Validation Pattern
```python
from pydantic import BaseModel, validator
from typing import Optional

class DetectionQuery(BaseModel):
    class_filter: Optional[str] = None
    min_confidence: float = 0.5
    max_depth: Optional[float] = None

    @validator('min_confidence')
    def validate_confidence(cls, v):
        if not 0 <= v <= 1:
            raise ValueError('Confidence must be between 0 and 1')
        return v

    @validator('class_filter')
    def validate_class(cls, v):
        valid_classes = ['person', 'car', 'chair', 'bottle']  # COCO classes
        if v and v not in valid_classes:
            raise ValueError(f'Invalid class: {v}')
        return v
```

**Security Benefits:**
- **Input Sanitization**: Prevent injection attacks
- **Type Safety**: Runtime type checking and validation
- **Business Logic**: Domain-specific validation rules
- **Error Handling**: Clear error messages for invalid inputs

### Rate Limiting Pattern
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

app = Flask(__name__)
limiter = Limiter(app, key_func=get_remote_address)

@app.route('/api/detections')
@limiter.limit("30 per minute")
def get_detections():
    return jsonify(get_current_detections())

@app.route('/api/ollama/prompt')
@limiter.limit("10 per minute")
def ollama_prompt():
    # Expensive AI operation - more restrictive limit
    return process_ollama_request()
```

**Protection:**
- **API Abuse Prevention**: Limit request frequency
- **Resource Protection**: Prevent resource exhaustion
- **Fair Usage**: Ensure equitable access for all users
- **Monitoring**: Track usage patterns and anomalies

## 📈 Performance Patterns

### Caching Pattern: LRU Cache
```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=128)
def cached_detection(frame_hash: str, config_hash: str) -> DetectionResult:
    """Cache detection results for similar frames"""
    return perform_detection(frame_hash, config_hash)

def get_frame_hash(frame: np.ndarray) -> str:
    """Generate hash for frame deduplication"""
    return hashlib.md5(frame.tobytes()).hexdigest()
```

**Benefits:**
- **Performance**: Avoid redundant processing of similar frames
- **Memory Efficiency**: LRU eviction prevents memory bloat
- **Scalability**: Handle higher frame rates with caching
- **Accuracy**: Consistent results for identical inputs

### Connection Pooling Pattern
```python
import aiohttp
from aiohttp import ClientSession

class OllamaClient:
    def __init__(self, base_url: str, pool_size: int = 10):
        self.base_url = base_url
        self.pool_size = pool_size
        self._session = None

    async def __aenter__(self):
        connector = aiohttp.TCPConnector(limit=self.pool_size)
        self._session = ClientSession(connector=connector)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self._session:
            await self._session.close()

    async def query(self, prompt: str) -> str:
        async with self._session.post(
            f"{self.base_url}/api/generate",
            json={"model": "llama2", "prompt": prompt}
        ) as response:
            data = await response.json()
            return data["response"]
```

**Advantages:**
- **Resource Efficiency**: Reuse connections to Ollama service
- **Performance**: Reduced connection overhead
- **Reliability**: Better handling of network issues
- **Scalability**: Support multiple concurrent requests

## 🔧 Maintenance Patterns

### Health Check Pattern
```python
class HealthChecker:
    def __init__(self):
        self.checks = {
            'camera': self._check_camera,
            'detector': self._check_detector,
            'ollama': self._check_ollama,
            'api': self._check_api
        }

    def run_all_checks(self) -> Dict[str, bool]:
        results = {}
        for name, check_func in self.checks.items():
            try:
                results[name] = check_func()
            except Exception as e:
                logger.error(f"Health check failed for {name}: {e}")
                results[name] = False
        return results

    def _check_camera(self) -> bool:
        try:
            ctx = rs.context()
            return len(ctx.query_devices()) > 0
        except:
            return False

    def _check_detector(self) -> bool:
        return self.detector is not None and self.detector.is_initialized

    def _check_ollama(self) -> bool:
        try:
            response = requests.get("http://localhost:11434/api/tags", timeout=5)
            return response.status_code == 200
        except:
            return False

    def _check_api(self) -> bool:
        return self.api_server is not None and self.api_server.is_running
```

**Monitoring:**
- **System Health**: Comprehensive health status reporting
- **Automated Recovery**: Self-healing capabilities
- **Alert Generation**: Proactive issue notification
- **Performance Tracking**: Health check timing and success rates

---

*These system patterns provide the architectural foundation for building maintainable, scalable, and robust computer vision applications with the Object Detection platform.*
