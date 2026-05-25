#!/bin/bash
export SECONDS=0
source .devcontainer/util/source_framework.sh

setUpTerminal

printInfoSection "Installing Python dependencies"
pip install --break-system-packages -r app/requirements.txt --quiet || printWarn "Some dependencies failed — run: pip install --break-system-packages -r app/requirements.txt"

printInfoSection "Configuring workshop credentials"

SECRETS_SERVER_URL="${SECRETS_SERVER_URL:-https://workshop-secrets-server.azurewebsites.net/api}"
ENV_FILE="${REPO_PATH}/.env"
BASHRC_FILE="$HOME/.bashrc"

_add_to_bashrc() {
    local var_name="$1" var_value="$2"
    sed -i "/^export ${var_name}=/d" "$BASHRC_FILE" 2>/dev/null || true
    echo "export ${var_name}=\"${var_value}\"" >> "$BASHRC_FILE"
}

# Create .env template if missing
if [ ! -f "$ENV_FILE" ]; then
    cat > "$ENV_FILE" << 'ENVEOF'
# Dynatrace Configuration — fill in your credentials
# Include /api/v2/otlp at the end of DT_ENDPOINT
# Example: DT_ENDPOINT=https://abc12345.live.dynatrace.com/api/v2/otlp
DT_ENDPOINT=
DT_API_TOKEN=
ENVEOF
fi

# Populate .env from Codespace secrets if available
if [ -n "$DT_ENVIRONMENT" ]; then
    local_dt_endpoint="${DT_ENVIRONMENT}/api/v2/otlp"
    sed -i "s|^DT_ENDPOINT=.*|DT_ENDPOINT=${local_dt_endpoint}|" "$ENV_FILE"
    printInfo "DT_ENDPOINT set from Codespace secret"
fi
if [ -n "$DT_API_TOKEN" ]; then
    sed -i "s|^DT_API_TOKEN=.*|DT_API_TOKEN=${DT_API_TOKEN}|" "$ENV_FILE"
    printInfo "DT_API_TOKEN set from Codespace secret"
fi

# Set ATTENDEE_ID
if [ -n "$ATTENDEE_ID" ]; then
    _add_to_bashrc "ATTENDEE_ID" "${ATTENDEE_ID}"
    printInfo "Attendee ID: ${ATTENDEE_ID}"
else
    RANDOM_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
    ATTENDEE_ID="attendee-${RANDOM_ID}"
    _add_to_bashrc "ATTENDEE_ID" "${ATTENDEE_ID}"
    printInfo "Generated attendee ID: ${ATTENDEE_ID}"
fi

# Auto-fetch Azure OpenAI credentials if WORKSHOP_TOKEN is set as a Codespace secret
if [ -n "$WORKSHOP_TOKEN" ]; then
    printInfo "Workshop token found — fetching Azure OpenAI credentials..."
    if ! command -v jq &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq jq > /dev/null 2>&1
    fi
    response=$(curl -s -w "\n%{http_code}" -X POST "${SECRETS_SERVER_URL}/get-credentials" \
        -H "Content-Type: application/json" \
        -d "{\"workshop_token\": \"${WORKSHOP_TOKEN}\"}" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    if [ "$http_code" = "200" ] && command -v jq &>/dev/null; then
        _add_to_bashrc "AZURE_OPENAI_ENDPOINT" "$(echo "$body" | jq -r '.azure_openai_endpoint // empty')"
        _add_to_bashrc "AZURE_OPENAI_API_KEY" "$(echo "$body" | jq -r '.azure_openai_api_key // empty')"
        _add_to_bashrc "AZURE_OPENAI_CHAT_DEPLOYMENT" "$(echo "$body" | jq -r '.azure_openai_chat_deployment // empty')"
        _add_to_bashrc "AZURE_OPENAI_EMBEDDING_DEPLOYMENT" "$(echo "$body" | jq -r '.azure_openai_embedding_deployment // empty')"
        _add_to_bashrc "AZURE_OPENAI_API_VERSION" "$(echo "$body" | jq -r '.azure_openai_api_version // empty')"
        _add_to_bashrc "DT_MCP_BEARER_TOKEN" "$(echo "$body" | jq -r '.dt_mcp_bearer_token // empty')"
        printInfo "Azure OpenAI credentials configured automatically"
    else
        printWarn "Could not auto-fetch credentials (HTTP ${http_code})"
        printWarn "Run manually: bash .devcontainer/fetch-secrets.sh"
    fi
else
    printWarn "WORKSHOP_TOKEN not set as Codespace secret"
    printWarn "Run: bash .devcontainer/fetch-secrets.sh"
fi

# Step needed — do not remove
finalizePostCreation

printInfoSection "Workshop environment ready"
printInfo "Next steps:"
printInfo "  1. Add your credentials to .env (DT_ENDPOINT, DT_API_TOKEN)"
printInfo "  2. Run: source ~/.bashrc"
printInfo "  3. Run: python app/main.py"
printInfo "  4. Open port 8000 in your browser"
printInfo ""
printInfo "Workshop guide: https://dynatrace-wwse.github.io/enablement-dynatrace-ai-mcp/"
