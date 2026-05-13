# Lab 0: Environment Setup

**Duration:** ~15 minutes

In this lab, you'll set up your workshop environment using GitHub Codespaces and configure the necessary credentials.

---

## Prerequisites

Before starting, ensure you have:

- A GitHub account
- Dynatrace credentials (provided by your instructor)
- Access to this workshop repository

---

## Attendee ID

Throughout this workshop, replace `{YOUR_ATTENDEE_ID}` with your chosen attendee ID (e.g., your name or initials like `jsmith`). This ID uniquely identifies your service in Dynatrace.

---

## Step 1: Launch GitHub Codespace

1. Click the button below to launch your personal workshop environment:

   [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/dynatrace-wwse/enablement-dynatrace-ai-mcp?quickstart=1)

2. Wait for the Codespace to build (2-3 minutes on first launch)

3. Once ready, you'll see VS Code in your browser with the workshop files

!!! tip
    Each attendee gets their own **isolated Codespace**. All your code changes stay within your Codespace and won't affect other workshop participants.

---

## Step 2: Configure Workshop Credentials

After the Codespace starts, configure credentials.

### 2.1 Run the Setup Script

In the VS Code terminal:

```bash
bash .devcontainer/fetch-secrets.sh
```

### 2.2 Enter Your Credentials

You'll be prompted for:

1. **Attendee ID** — Enter your ID (e.g., `{YOUR_ATTENDEE_ID}`)
2. **Workshop Token** — Your instructor will provide this

```
🔐 Workshop Credentials Setup

Enter your attendee ID (e.g., your name or initials, no spaces) [press enter to generate]: {YOUR_ATTENDEE_ID}
✅ Attendee ID: {YOUR_ATTENDEE_ID}

Enter your workshop token: *INSTRUCTOR PROVIDED*
✅ Azure OpenAI credentials configured!
```

### 2.3 Load Your Credentials

```bash
source ~/.bashrc
```

Then reload VS Code:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Run: **Developer: Reload Window**

---

## Step 3: Configure Dynatrace Credentials

### 3.1 Open the Environment File

In the VS Code Explorer, open the `.env` file in the root directory.

### 3.2 Add Dynatrace Credentials

Your instructor will provide the following values:

```bash
# Include /api/v2/otlp at the end of DT_ENDPOINT
DT_ENDPOINT=https://YOUR_ENV.live.dynatrace.com/api/v2/otlp
DT_API_TOKEN=dt0c01.XXXXXXXXXX.YYYYYYYYYYYYYYYY
```

### 3.3 Verify Configuration

```bash
echo "Attendee: $ATTENDEE_ID"
echo "Azure OpenAI: ${AZURE_OPENAI_ENDPOINT:+configured}"
```

!!! info
    Azure OpenAI credentials and your Attendee ID are stored as environment variables (not in `.env`) for security.

---

## Step 4: Verify the Sample Application

### 4.1 Start the Application

```bash
python app/main.py
```

### 4.2 Expected Output

```
╔══════════════════════════════════════════════════════════════════════╗
║         🚀 AI Chat Service Starting...                               ║
║                                                                      ║
║         Attendee ID: {YOUR_ATTENDEE_ID}                              ║
║         Service: ai-chat-service-{YOUR_ATTENDEE_ID}                  ║
╚══════════════════════════════════════════════════════════════════════╝

✅ RAG initialized successfully for attendee: {YOUR_ATTENDEE_ID}
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

### 4.3 Test the Application

1. When the application starts, VS Code shows a popup about port 8000 — click **"Open in Browser"**
2. You should see the **AI Chat Interface**
3. Try sending: `"What is Dynatrace?"`
4. You should receive an AI-generated response

!!! tip
    If you miss the popup, click the **Ports** tab in VS Code, find port 8000, and click the globe icon.

### 4.4 Stop the Application

Press `Ctrl+C` in the terminal.

---

## Checkpoint

Before proceeding to Lab 1, verify:

- [ ] Your Codespace is running
- [ ] You've set your Attendee ID (remember it — you'll use it throughout)
- [ ] The `.env` file has `DT_ENDPOINT` and `DT_API_TOKEN` from your instructor
- [ ] The sample application starts without errors
- [ ] You can access the application in your browser
- [ ] The chat endpoint responds with AI-generated text

---

## Troubleshooting

**"Azure OpenAI credentials not found"**

```bash
bash .devcontainer/fetch-secrets.sh
```

Enter the workshop token from your instructor.

**"Invalid workshop token"** — Double-check for extra spaces. Ask your instructor.

**Application crashes on startup** — Check `.env` for typos. Run `pip install -r app/requirements.txt`.

**"Connection refused" on port 8000** — Check the Ports tab in VS Code.

---

[← Home](index.md) | [Lab 1: Instrumentation →](lab1-instrumentation.md)
