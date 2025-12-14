#!/bin/bash
set -euo pipefail

# Healthcheck and auto-restart script for KitchenTech
# Usage: Run every 5 minutes via systemd timer
# Checks: Frontend and API health
# Action: Restart backend service if API is down

LOG_FILE="/var/log/souqmatbakh/healthcheck.log"
STATE_FILE="/var/run/souqmatbakh-healthcheck.state"
FRONTEND_URL="https://souqmatbakh.com/"
API_URL="https://souqmatbakh.com/api/"
SERVICE_NAME="souqmatbakh-backend"
TIMEOUT=10

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

# Logging function (only log on state changes to avoid spam)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "${LOG_FILE}"
}

# Check if we need to log (avoid spam)
should_log() {
    local current_state="$1"
    local previous_state=""
    
    if [[ -f "${STATE_FILE}" ]]; then
        previous_state=$(cat "${STATE_FILE}")
    fi
    
    # Log if state changed or if this is a failure/critical event
    if [[ "${current_state}" != "${previous_state}" ]] || [[ "${current_state}" == "FAILED" ]] || [[ "${current_state}" == "CRITICAL" ]]; then
        echo "${current_state}" > "${STATE_FILE}"
        return 0
    fi
    
    return 1
}

# Check frontend health (HTTP 200 or 301/302 redirect acceptable)
FRONTEND_STATUS=0
if curl -fsS -m "${TIMEOUT}" -o /dev/null -w "%{http_code}" "${FRONTEND_URL}" | grep -qE '^(200|301|302)$'; then
    FRONTEND_STATUS=0
else
    FRONTEND_STATUS=1
    if should_log "FRONTEND_DEGRADED"; then
        log "WARNING: Frontend check failed for ${FRONTEND_URL}"
    fi
fi

# Check API health (must return 200)
API_STATUS=0
if ! curl -fsS -m "${TIMEOUT}" -o /dev/null -w "%{http_code}" "${API_URL}" | grep -q '^200$'; then
    API_STATUS=1
    if should_log "API_FAILED"; then
        log "ERROR: API health check failed for ${API_URL}"
        log "ACTION: Attempting to restart ${SERVICE_NAME}"
    fi
    
    # Restart backend service
    if systemctl restart "${SERVICE_NAME}"; then
        log "INFO: Service ${SERVICE_NAME} restarted successfully"
        
        # Wait a few seconds for service to start
        sleep 5
        
        # Re-check API health
        if curl -fsS -m "${TIMEOUT}" -o /dev/null -w "%{http_code}" "${API_URL}" | grep -q '^200$'; then
            if should_log "RECOVERED"; then
                log "SUCCESS: API recovered after restart"
            fi
            exit 0
        else
            if should_log "CRITICAL"; then
                log "CRITICAL: API still failing after restart - manual intervention required"
            fi
            exit 1
        fi
    else
        if should_log "CRITICAL"; then
            log "CRITICAL: Failed to restart ${SERVICE_NAME} - manual intervention required"
        fi
        exit 1
    fi
fi

# All checks passed
if should_log "HEALTHY"; then
    log "INFO: All health checks passed"
fi

exit 0
