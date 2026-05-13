# Lab 4: Workflow Automation — Become the AI Cost Guardian

**Duration:** ~30 minutes

In this lab, you'll create automated workflows that transform you from someone who *monitors* AI costs to someone who *controls* them. This is your "hero moment" — building automation you can take back to your team.

---

## Learning Objectives

- Create a Dynatrace Workflow for AI observability
- Set up automated token usage monitoring
- Configure alerts that matter (not noise)
- Build a daily AI cost summary automation
- Understand the Dynatrace automation advantage

---

!!! tip "Why Dynatrace? The Automation Advantage"
    | Capability | Other Tools | Dynatrace |
    |------------|-------------|-----------|
    | Trace collection | ✅ Manual thresholds | ✅ Davis AI anomaly detection |
    | Alert configuration | ❌ You define every threshold | ✅ Auto-baselines, smart alerts |
    | Root cause | ❌ You investigate | ✅ Davis AI automatic RCA |
    | Remediation | ❌ External tools | ✅ Built-in Workflows + integrations |
    | Context | Token counts only | ✅ Tokens + infrastructure + user impact |

    **The difference:** Other tools tell you *something is wrong*. Dynatrace tells you *what's wrong, why, and can fix it automatically*.

---

## Step 1: Navigate to Workflows

In Dynatrace, click on the **Workflows** app in the left navigation (or search for it).

---

## Choose Your Persona

Complete at least one workflow from your persona path.

---

## 💻 Developer Path: Token Usage Alert

**Goal:** Create workflows that alert you before users complain. Sleep better knowing automation has your back.

### Step 2: Create a Token Usage Alert Workflow

#### 2.1 Create a New Workflow

1. Click **+ Workflow**
2. Name it: `Token Usage Alert - {YOUR_ATTENDEE_ID}`

#### 2.2 Set the Trigger

1. Click on the trigger block
2. Select **Time Interval trigger**: run every **15 minutes** for testing

#### 2.3 Add a DQL Query Action

1. Click **+ Add task**
2. Select **Execute DQL query**
3. Name this task: `get_token_usage`
4. Enter this query:

```sql
fetch spans
| filter service.name == "ai-chat-service-{YOUR_ATTENDEE_ID}"
| filter isNotNull(gen_ai.usage.input_tokens)
| summarize 
    total_input_tokens = sum(gen_ai.usage.input_tokens),
    total_output_tokens = sum(gen_ai.usage.output_tokens),
    request_count = count()
| fieldsAdd total_tokens = total_input_tokens + total_output_tokens
| fieldsAdd estimated_cost_usd = (total_input_tokens * 2.50 + total_output_tokens * 10.00) / 1000000
```

#### 2.4 Add a Notification Action

Add an **Email** → **Send email** task. Configure your message:

{% raw %}
```
🚨 AI Token Alert - {YOUR_ATTENDEE_ID}

Token usage exceeded threshold!

📊 Stats:
• Total Tokens: {{ result("get_token_usage").records[0].total_tokens }}
• Input Tokens: {{ result("get_token_usage").records[0].total_input_tokens }}
• Output Tokens: {{ result("get_token_usage").records[0].total_output_tokens }}
• Estimated Cost: ${{ result("get_token_usage").records[0].estimated_cost_usd | round(4) }}
• Request Count: {{ result("get_token_usage").records[0].request_count }}
```
{% endraw %}

#### 2.5 Add a Condition

Select **Condition** and set:

{% raw %}
```
{{ result("get_token_usage").records[0].total_tokens > 1000 }}
```
{% endraw %}

Adjust threshold based on your expected usage.

#### 2.6 Save and Run

1. Click **Create/Save draft**
2. Click **Run**

---

## 🔧 SRE/Platform Path: Daily AI Cost Summary

**Goal:** Build the automation that makes you the AI Cost Guardian!

### Step 3: Daily AI Cost Summary Workflow

#### 3.1 Create a New Workflow

1. Click **+ Workflow**
2. Name it: `Daily AI Summary - {YOUR_ATTENDEE_ID}`

#### 3.2 Set Schedule Trigger

1. Select **Fix Time trigger**
2. Configure: **Daily at 9:00 AM** (or your preferred time)

#### 3.3 Add Comprehensive DQL Query

Add an **Execute DQL query** task named `usage`:

```sql
fetch spans
| filter service.name == "ai-chat-service-{YOUR_ATTENDEE_ID}"
| filter isNotNull(gen_ai.usage.input_tokens)
| summarize 
    total_input = sum(gen_ai.usage.input_tokens),
    total_output = sum(gen_ai.usage.output_tokens),
    avg_input = avg(gen_ai.usage.input_tokens),
    avg_output = avg(gen_ai.usage.output_tokens),
    max_input = max(gen_ai.usage.input_tokens),
    request_count = count(),
  by: {span.name}
| sort total_input + total_output desc
| limit 10
```

#### 3.4 Add Summary Query

Add another **Execute DQL query** task named `cost`:

```sql
fetch spans
| filter service.name == "ai-chat-service-{YOUR_ATTENDEE_ID}"
| filter isNotNull(gen_ai.usage.input_tokens)
| summarize 
    total_input = sum(gen_ai.usage.input_tokens),
    total_output = sum(gen_ai.usage.output_tokens),
    total_requests = count(),
    avg_latency_ms = avg(duration) / 1000000
| fieldsAdd estimated_daily_cost = (total_input * 2.50 + total_output * 10.00) / 1000000
| fieldsAdd projected_monthly_cost = estimated_daily_cost * 30
```

#### 3.5 Send Daily Report

Add an **Email** → **Send email** task. Configure your message:

{% raw %}
```
📊 Daily AI Service Report - {YOUR_ATTENDEE_ID}

═══════════════════════════════════════
💰 COST SUMMARY
═══════════════════════════════════════
• Today's Estimated Cost: ${{ result("cost").records[0].estimated_daily_cost | round(4) }}
• Projected Monthly Cost: ${{ result("cost").records[0].projected_monthly_cost | round(2) }}

═══════════════════════════════════════
📈 USAGE METRICS
═══════════════════════════════════════
• Total Requests: {{ result("usage").records | map(attribute="request_count") | map("int") | sum }}
• Total Input Tokens: {{ result("usage").records | map(attribute="total_input") | map("int") | sum }}
• Total Output Tokens: {{ result("usage").records | map(attribute="total_output") | map("int") | sum }}
• Avg Response Time: {{ result("cost").records[0].avg_latency_ms }}ms
```
{% endraw %}

#### 3.6 Save and Run

1. Click **Create/Save draft**
2. Click **Run**

---

## Checkpoint

- [ ] Created a workflow
- [ ] Set up notification
- [ ] Tested workflow execution
- [ ] Understand how Davis AI can trigger workflows
- [ ] Know how to add conditions and notifications

---

## Troubleshooting

**"Workflow not triggering"** — Verify the workflow is **Enabled**. Use **Run** to test manually.

**"DQL query returns no data"** — Verify your service name matches exactly. Ensure your app has processed requests recently.

**"Notification not received"** — Verify the notification channel configuration.

---

## What You've Learned

### 💻 Developer Takeaways

1. Create scheduled workflows that run DQL queries
2. Set up token usage alerts with thresholds
3. Configure notifications (Slack, Teams, Email)
4. Add conditions to avoid alert noise

**Sleep better:** Your workflow alerts you if token usage spikes — before users complain or the bill arrives.

### 🔧 SRE/Platform Takeaways

1. Build daily cost summary workflows
2. Calculate projected monthly costs automatically
3. Identify top token consumers by operation
4. Trigger workflows from Davis AI problems

**Take back to your team:** These workflows are production-ready. Customize thresholds and notification channels for your environment.

---

## Take It Further

| Workflow | Trigger | Action |
|----------|---------|--------|
| **Cost Circuit Breaker** | Token rate > limit | Disable endpoint temporarily |
| **Model Fallback** | GPT-4 latency spike | Switch to GPT-4o-mini |
| **Weekly Executive Report** | Schedule (Monday 8am) | Email summary to leadership |
| **Prompt Injection Alert** | Unusual input patterns | Security team notification |
| **SLA Violation** | P95 latency > 5s | Create incident + page on-call |

---

[← Lab 3: Dynatrace MCP](lab3-dynatrace-mcp.md) | [Resources →](resources.md)
