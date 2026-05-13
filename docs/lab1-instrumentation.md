# Lab 1: AI Instrumentation with OpenLLMetry

**Duration:** ~15 minutes

In this lab, you'll add OpenLLMetry instrumentation to the sample RAG application to send traces to Dynatrace.

---

## Learning Objectives

- Understand how OpenLLMetry works with OpenTelemetry
- Add Traceloop instrumentation to a Python AI application
- Configure the exporter for Dynatrace OTLP ingestion
- Verify traces are being sent to Dynatrace

---

## Step 1: Install OpenLLMetry Dependencies

### 1.1 Update requirements.txt

Open `app/requirements.txt` and **uncomment** the following lines (remove the `#`):

```python
# Before (commented out):
# traceloop-sdk==0.50.1
# opentelemetry-exporter-otlp==1.39.1

# After (uncommented):
traceloop-sdk==0.50.1
opentelemetry-exporter-otlp==1.39.1
```

### 1.2 Install the Dependencies

```bash
pip install traceloop-sdk opentelemetry-exporter-otlp opentelemetry-instrumentation-fastapi
```

Expected output:

```
Successfully installed traceloop-sdk-0.50.1 opentelemetry-exporter-otlp-1.39.1 ...
```

---

## Step 2: Add Dynatrace Instrumentation

### 2.1 Open the Main Application File

Open `app/main.py` in VS Code.

### 2.2 Locate the Instrumentation Section

Find this comment block near the top of the file:

```python
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║  🔬 LAB 1: INSTRUMENTATION SECTION                                        ║
# ║                                                                           ║
# ║  TODO: Add Dynatrace OpenLLMetry instrumentation here                    ║
# ╚══════════════════════════════════════════════════════════════════════════╝

# ---> ADD YOUR INSTRUMENTATION CODE HERE <---
```

### 2.3 Add the Instrumentation Code

Replace `# ---> ADD YOUR INSTRUMENTATION CODE HERE <---` with:

```python
from traceloop.sdk import Traceloop

# Get Dynatrace configuration from environment
ATTENDEE_ID = os.getenv("ATTENDEE_ID", "workshop-attendee")
DT_ENDPOINT = os.getenv("DT_ENDPOINT")
DT_API_TOKEN = os.getenv("DT_API_TOKEN")

# ⚠️ IMPORTANT: Dynatrace requires Delta temporality for metrics
# This MUST be set before Traceloop.init()
os.environ["OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE"] = "delta"

# Initialize Traceloop with Dynatrace endpoint
if DT_ENDPOINT and DT_API_TOKEN:
    headers = {"Authorization": f"Api-Token {DT_API_TOKEN}"}
    Traceloop.init(
        app_name=f"ai-chat-service-{ATTENDEE_ID}",
        api_endpoint=DT_ENDPOINT,
        headers=headers
    )
    print(f"✅ Traceloop initialized - sending traces to Dynatrace")
    print(f"   Service Name: ai-chat-service-{ATTENDEE_ID}")
    print(f"   Endpoint: {DT_ENDPOINT}")
else:
    print("⚠️  Dynatrace configuration not found. Traceloop not initialized.")
    print("   Please set DT_ENDPOINT and DT_API_TOKEN in your .env file")
```

---

## Step 3: Understanding the Code

### 3.1 Import Statement

```python
from traceloop.sdk import Traceloop
```

The Traceloop SDK provides automatic instrumentation for LLM frameworks like OpenAI, LangChain, and more.

### 3.2 Delta Temporality Setting

```python
os.environ["OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE"] = "delta"
```

!!! warning "Critical for Dynatrace"
    Dynatrace expects metrics with **Delta temporality**, not Cumulative. This environment variable must be set **before** initializing Traceloop.

### 3.3 Traceloop Initialization

| Parameter | Description |
|-----------|-------------|
| `app_name` | Service name in Dynatrace (includes your attendee ID) |
| `api_endpoint` | The Dynatrace OTLP ingestion endpoint |
| `headers` | Authentication header with your API token |

---

## Step 4: Restart the Application

Stop if running (`Ctrl+C`), then:

```bash
python app/main.py
```

You should see:

```
✅ Traceloop initialized - sending traces to Dynatrace
   Service Name: ai-chat-service-{YOUR_ATTENDEE_ID}
   Endpoint: https://abc12345.live.dynatrace.com/api/v2/otlp
```

---

## Step 5: Generate Test Traffic

### 5.1 Open the Chat UI

When you start the app, Codespaces detects port 8000 and shows a popup — click **"Open in Browser"**.

### 5.2 Chat with the AI Assistant

Send several messages:

- "What is Dynatrace and what does it do?"
- "How does OpenTelemetry work with Dynatrace?"
- "Explain observability for AI applications"
- "What is the Dynatrace MCP?"

### 5.3 Toggle RAG Mode

- **RAG On:** Uses vector store to find relevant context before answering
- **RAG Off:** Sends question directly to the LLM without context

Try the same question both ways to see the difference!

### 5.4 What Gets Traced

| Span | Description |
|------|-------------|
| HTTP Request | Incoming FastAPI request |
| Embedding Generation | Azure OpenAI embeddings for vector search |
| Vector Store Query | ChromaDB retrieval |
| LLM Completion | Azure OpenAI chat completion |
| Token Usage | Input/output token counts |

---

## Checkpoint

- [ ] `traceloop-sdk` and `opentelemetry-exporter-otlp` packages installed
- [ ] Instrumentation code added to `main.py`
- [ ] Application starts with "✅ Traceloop initialized" message
- [ ] You've sent at least 3-4 chat requests
- [ ] No errors in the terminal

---

## Troubleshooting

**"Module traceloop not found"**

```bash
pip install traceloop-sdk opentelemetry-exporter-otlp
```

**"401 Unauthorized" in logs** — Check the token in `.env` has `openTelemetryTrace.ingest` permission.

**"Traceloop not initialized"** — Check `.env` has both `DT_ENDPOINT` and `DT_API_TOKEN`.

---

[← Lab 0: Setup](lab0-setup.md) | [Lab 2: Explore Traces →](lab2-explore-traces.md)
