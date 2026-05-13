# Lab 3: Using Dynatrace MCP for Agentic AI

**Duration:** ~30 minutes

In this lab, you'll configure and use the Dynatrace MCP (Model Context Protocol) server to interact with Dynatrace directly from your IDE using AI assistants like GitHub Copilot.

---

## Learning Objectives

- Understand what MCP is and how it enables agentic AI
- Configure the Dynatrace MCP server in VS Code
- Use natural language to query Dynatrace from VS Code
- Analyze problems and traces using AI assistance
- Explore real-world use cases for observability-driven AI

---

## What is MCP?

**Model Context Protocol (MCP)** is an open standard that allows AI assistants to interact with external tools and data sources. With Dynatrace MCP, you can:

- Query Dynatrace using natural language
- Analyze problems and incidents
- Retrieve metrics, traces, and logs
- Get AI-powered insights about your applications

Think of it as giving your AI assistant **direct access to Dynatrace**!

!!! tip "Why Dynatrace MCP is Different"
    | Capability | Basic AI Assistants | Dynatrace MCP |
    |------------|---------------------|---------------|
    | Query observability data | ❌ No access | ✅ Natural language queries |
    | Correlate AI + infrastructure | ❌ Separate tools | ✅ Unified view via Davis AI |
    | Root cause analysis | ❌ You investigate | ✅ Davis AI explains issues |
    | Take action | ❌ Copy/paste to other tools | ✅ Trigger workflows from IDE |
    | Business context | ❌ Technical data only | ✅ Link tokens to user impact |

---

## Step 1: Configure the Dynatrace MCP Server

### 1.1 Open the MCP Configuration File

In VS Code, open `.vscode/mcp.json`. You'll see:

```json
{
  "servers": {
    "Dynatrace-MCP": {
      "type": "sse",
      "url": "https://YOUR_TENANT_ID.apps.dynatrace.com/platform-reserved/mcp-gateway/v0.1/servers/dynatrace-mcp/mcp",
      "headers": {
        "Authorization": "Bearer ${env:DT_MCP_BEARER_TOKEN}"
      }
    }
  }
}
```

### 1.2 Update Your Dynatrace Tenant URL

Replace `YOUR_TENANT_ID` with your actual Dynatrace environment ID:

- If your Dynatrace URL is `https://abc12345.apps.dynatrace.com`
- Then your URL becomes: `https://abc12345.apps.dynatrace.com/platform-reserved/mcp-gateway/v0.1/servers/dynatrace-mcp/mcp`

Save the file.

!!! info "About the Authorization Token"
    The `${env:DT_MCP_BEARER_TOKEN}` is automatically configured by the `fetch-secrets.sh` script you ran in Lab 0. No need to set it manually.

### 1.3 Reload VS Code

After saving the configuration:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Run: **Developer: Reload Window**

---

## Step 2: Verify MCP Connection

### 2.1 Open GitHub Copilot Chat

1. Click on the Copilot icon on the top bar
2. Or use: `Cmd+Shift+I` (Mac) / `Ctrl+Shift+I` (Windows)

### 2.2 Test the Connection

In the Copilot chat, type:

```
@dynatrace What services are available in my environment?
```

If configured correctly, Copilot will query Dynatrace and return a list of services!

---

## Dynatrace Intelligence ✨

Dynatrace Intelligence provides agentic workflows that go beyond simple queries. When running the queries below, notice how your AI agent interacts with various Dynatrace agents (Grail Query Agent, Data Analysis Agent, Root Cause Agent, etc.).

Learn more:

- [Dynatrace Intelligence — Announcement](https://www.dynatrace.com/news/blog/dynatrace-intelligence-at-the-core-of-autonomous-operations/)
- [Dynatrace Intelligence — Documentation](https://docs.dynatrace.com/docs/shortlink/dynatrace-intelligence-landing)

---

## Choose Your Persona

---

## 💻 Developer: "I want to debug without leaving my IDE"

**Your story:** You're deep in code, fixing a bug in your RAG pipeline. Every time you need performance data, you context-switch to Dynatrace. With MCP, you can just *ask*.

### Step 3: Query Your AI Service (Developer)

#### 3.1 Find Your Service

```
@dynatrace Tell me about the service called ai-chat-service-{YOUR_ATTENDEE_ID}
```

#### 3.2 Analyze Token Usage

```
@dynatrace What is the total input and output token usage for spans in regards to the ai-chat-service-{YOUR_ATTENDEE_ID}
```

#### 3.3 Debug While You Code

```
I'm looking at main.py where I call Azure OpenAI.
@dynatrace What's the average latency for Azure OpenAI calls from my ai-chat-service-{YOUR_ATTENDEE_ID} service?
```

---

### Step 4: Agentic Debugging Workflows (Developer)

#### 4.1 Find the Bottleneck

```
I'm seeing slow responses in my RAG pipeline. 
@dynatrace Analyze the trace data and tell me which step is the bottleneck for my ai-chat-service-{YOUR_ATTENDEE_ID} service.
Is it embeddings, vector search, or the LLM call?
```

#### 4.2 Proactive Analysis

```
@dynatrace Analyze my ai-chat-service-{YOUR_ATTENDEE_ID} service and suggest optimizations to reduce token usage while maintaining response quality
```

#### 4.3 Debugging Assistance

```
@dynatrace Help me understand why some of my RAG queries might be slow. Look at the trace data for patterns.
```

---

### Step 4.4: Investigate Errors with MCP (Developer)

#### Generate Errors

1. Go to your AI Chat Service UI (http://localhost:8000)
2. Enable the **🐛 Simulate Errors** toggle
3. Send 5-10 messages to trigger various error types

The app will randomly generate realistic RAG/LLM errors:

- `EMB_NULL_VECTOR`: Embedding service returning null vectors
- `CHROMA_COLLECTION_ERR`: Vector store connection issues
- `LLM_MALFORMED_RESPONSE`: Invalid LLM responses
- `CTX_WINDOW_EXCEEDED`: Context window limit errors
- `CONTENT_FILTER_BLOCK`: Content policy violations

#### Find Your Errors

```
@dynatrace Show me all errors in the last 15 minutes for my ai-chat-service-{YOUR_ATTENDEE_ID} service.
What error codes are appearing most frequently?
```

#### View Log Entries

```
@dynatrace Show me the log entries for EMB_NULL_VECTOR errors in my ai-chat-service-{YOUR_ATTENDEE_ID}.
Include the error_message, stage, and timestamp for each.
```

#### Deep Dive on a Specific Error

```
@dynatrace I'm seeing CTX_WINDOW_EXCEEDED errors in my ai-chat-service-{YOUR_ATTENDEE_ID} service. 
Show me the full log details for these errors and explain what's happening.
```

#### Get Root Cause Analysis

```
@dynatrace What's causing the errors in my ai-chat-service-{YOUR_ATTENDEE_ID} service?
Analyze the error logs and tell me which component is failing most often.
```

---

## 🔧 SRE/Platform: "I need faster incident response"

**Your story:** It's 2 AM and you get paged. Instead of fumbling through dashboards, you can ask about the issue.

### Step 5: Query Your AI Service (SRE)

#### 5.1 Find Your Service

```
@dynatrace Tell me about the service called ai-chat-service-{YOUR_ATTENDEE_ID}
```

#### 5.2 Check for Anomalies

```
@dynatrace Are there any anomalies in the last hour for my ai-chat-service-{YOUR_ATTENDEE_ID} service?
What's the current error rate and how does it compare to the baseline?
```

#### 5.3 Analyze Token Usage

```
@dynatrace What is the total input and output token usage for spans in regards to the ai-chat-service-{YOUR_ATTENDEE_ID} service?
```

---

### Step 6: Agentic Incident Response (SRE)

#### 6.1 Incident Response

```
@dynatrace Are there any open problems affecting my ai-chat-service-{YOUR_ATTENDEE_ID} service?
If so, what's the root cause and which services are impacted?
Draft a Slack message summarizing the incident.
```

#### 6.2 Service Architecture

```
@dynatrace Generate a summary of my ai-chat-service-{YOUR_ATTENDEE_ID} service's architecture based on the service flow data
```

#### 6.3 Capacity Planning

```
@dynatrace Analyze my ai-chat-service-{YOUR_ATTENDEE_ID} service and suggest optimizations to reduce token usage while maintaining response quality
```

---

### Step 6.4: Error Triage with MCP (SRE)

#### Generate Errors

1. Go to your AI Chat Service UI (http://localhost:8000)
2. Enable the **🐛 Simulate Errors** toggle
3. Send 10-15 messages rapidly

#### Rapid Error Assessment

```
@dynatrace Give me a quick summary of all errors hitting my ai-chat-service-{YOUR_ATTENDEE_ID} service in the last 15 minutes.
How many errors occurred? What types? What's the error rate percentage?
```

#### Analyze Error Timeline

```
@dynatrace When did errors start occurring in my ai-chat-service-{YOUR_ATTENDEE_ID} service?
Show me the timeline of errors over the last 15 minutes.
```

#### Root Cause with Dynatrace Intelligence

```
@dynatrace Analyze the error patterns in my ai-chat-service-{YOUR_ATTENDEE_ID} service.
What is Dynatrace Intelligence's assessment of the root cause?
Which component is the source of the failures?
```

#### Create Incident Communication

```
@dynatrace I need to communicate an incident to stakeholders.
Based on the errors in my ai-chat-service-{YOUR_ATTENDEE_ID} service, draft a brief incident summary
including: affected service, error types, error rate, and preliminary root cause.
```

---

## Bonus: Dynatrace Intelligence in the Dynatrace Platform

Try Dynatrace Intelligence directly in the UI:

1. Open a Dynatrace Notebook
2. Add a **✨ Prompt** tile
3. Try:

```
I would like to see top 5 spans summarized by token usage and span name for service "ai-chat-service-{YOUR_ATTENDEE_ID}" in descending order
```

Dynatrace Intelligence is available in: Problems app, Notebooks, Dashboards, Logs app, Databases app, and more.

---

## Going Beyond the Basics

### 💻 Developer: Propose & Fix Regressions

```
@dynatrace Look at the error traces for my ai-chat-service-{YOUR_ATTENDEE_ID} service.
Can you identify which function or code path is causing the failures?
```

```
@dynatrace Based on the EMB_NULL_VECTOR errors in my ai-chat-service-{YOUR_ATTENDEE_ID} service, 
what code changes would you recommend to handle this error gracefully?
Show me a Python code example for proper error handling.
```

```
@dynatrace Generate a DQL query to find all logs where error_code equals 'CTX_WINDOW_EXCEEDED' 
for my ai-chat-service-{YOUR_ATTENDEE_ID} service in the last hour.
Explain what the query does.
```

### 🔧 SRE: Agentic Incident Response

```
@dynatrace For the errors in my ai-chat-service-{YOUR_ATTENDEE_ID} service, 
show me the full dependency map. Which downstream services are affected?
```

```
@dynatrace Create a comprehensive incident report for the issues affecting 
my ai-chat-service-{YOUR_ATTENDEE_ID} service. Include:
- Timeline of when errors started
- Affected components and their relationships
- Error counts by type
- Recommended severity level
```

```
@dynatrace Generate a DQL query for a dashboard tile that shows:
- Error rate over time for my ai-chat-service-{YOUR_ATTENDEE_ID} service
- Breakdown by error_code
- 5-minute time buckets for the last hour
```

---

## Step 7: MCP Best Practices

**Good prompts are specific:**

✅ Good: `@dynatrace Show me the P95 response time for my ai-chat-service-{YOUR_ATTENDEE_ID} service over the last 4 hours`

❌ Vague: `@dynatrace How is my service doing?`

**Iterative queries — start broad, drill down:**

1. `@dynatrace Show me an overview of my AI service`
2. `@dynatrace What are the slowest endpoints?`
3. `@dynatrace Why is /chat endpoint slow?`
4. `@dynatrace Show me slow traces for /chat`

---

## Checkpoint

- [ ] Updated `YOUR_TENANT_ID` in `.vscode/mcp.json`
- [ ] Reloaded VS Code after saving the configuration
- [ ] Can query Dynatrace using `@dynatrace` in Copilot Chat
- [ ] Retrieved information about your AI service
- [ ] Used 🐛 Simulate Errors to generate test errors
- [ ] Investigated errors using MCP without leaving your IDE
- [ ] Explored Dynatrace Intelligence agentic workflows

---

## Troubleshooting

**"@dynatrace not recognized"**

1. Check that `.vscode/mcp.json` has the correct tenant URL
2. Verify JSON syntax is valid
3. Reload VS Code window (`Developer: Reload Window`)

**"Authentication failed" or "401 Unauthorized"**

1. Verify your tenant URL in `.vscode/mcp.json` — format: `https://YOUR_ENV_ID.apps.dynatrace.com/...`
2. Verify `DT_MCP_BEARER_TOKEN` is set: `echo $DT_MCP_BEARER_TOKEN`
3. If empty, re-run: `bash .devcontainer/fetch-secrets.sh`

**"No data returned"**

1. Check your service is sending data to Dynatrace
2. Try a simpler query: `@dynatrace List all services`

---

[← Lab 2: Explore Traces](lab2-explore-traces.md) | [Lab 4: Automation →](lab4-automation.md)
