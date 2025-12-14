#!/bin/bash
set -euo pipefail

# Ops Pack Verification Script
# Verifies that all operational components are running correctly
# Usage: sudo bash deploy/scripts/ops_verify.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_check() {
    echo -n "Checking $1... "
}

print_pass() {
    echo -e "${GREEN}PASS${NC}"
    ((PASS_COUNT++))
}

print_fail() {
    echo -e "${RED}FAIL${NC} - $1"
    ((FAIL_COUNT++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Main checks
print_header "KitchenTech Ops Pack Verification"

# Check 1: Backend service
print_check "Backend service status"
if systemctl is-active --quiet souqmatbakh-backend; then
    print_pass
else
    print_fail "Service not running"
fi

# Check 2: Backup timer
print_check "Backup timer enabled"
if systemctl is-enabled --quiet souqmatbakh-backup.timer; then
    print_pass
else
    print_fail "Timer not enabled"
fi

# Check 3: Backup timer active
print_check "Backup timer running"
if systemctl is-active --quiet souqmatbakh-backup.timer; then
    print_pass
else
    print_fail "Timer not active"
fi

# Check 4: Healthcheck timer enabled
print_check "Healthcheck timer enabled"
if systemctl is-enabled --quiet souqmatbakh-healthcheck.timer; then
    print_pass
else
    print_fail "Timer not enabled"
fi

# Check 5: Healthcheck timer active
print_check "Healthcheck timer running"
if systemctl is-active --quiet souqmatbakh-healthcheck.timer; then
    print_pass
else
    print_fail "Timer not active"
fi

# Check 6: Frontend accessibility
print_check "Frontend (https://souqmatbakh.com)"
if curl -fsS -m 10 -o /dev/null -w "%{http_code}" https://souqmatbakh.com | grep -qE '^(200|301|302)$'; then
    print_pass
else
    print_fail "Frontend not accessible"
fi

# Check 7: API health
print_check "API (https://souqmatbakh.com/api/)"
if curl -fsS -m 10 -o /dev/null -w "%{http_code}" https://souqmatbakh.com/api/ | grep -q '^200$'; then
    print_pass
else
    print_fail "API not responding with 200"
fi

# Check 8: Log directory exists
print_check "Log directory exists"
if [[ -d /var/log/souqmatbakh ]]; then
    print_pass
else
    print_fail "Directory /var/log/souqmatbakh not found"
fi

# Check 9: Backup directory exists
print_check "Backup directory exists"
if [[ -d /var/backups/souqmatbakh ]]; then
    print_pass
else
    print_fail "Directory /var/backups/souqmatbakh not found"
fi

# Check 10: Backup script executable
print_check "Backup script executable"
if [[ -x /var/www/souqmatbakh/deploy/scripts/backup_postgres_and_uploads.sh ]]; then
    print_pass
else
    print_fail "Script not found or not executable"
fi

# Check 11: Healthcheck script executable
print_check "Healthcheck script executable"
if [[ -x /var/www/souqmatbakh/deploy/scripts/healthcheck_and_restart.sh ]]; then
    print_pass
else
    print_fail "Script not found or not executable"
fi

# Timer information
print_header "Systemd Timers Status"
systemctl list-timers --no-pager | grep -E '(souqmatbakh|NEXT)' || echo "No souqmatbakh timers found"

# Recent logs
print_header "Recent Log Entries"

echo -e "${BLUE}Backup Log (last 5 lines):${NC}"
if [[ -f /var/log/souqmatbakh/backup.log ]]; then
    tail -n 5 /var/log/souqmatbakh/backup.log || echo "No backup logs yet"
else
    echo "No backup log file found"
fi

echo ""
echo -e "${BLUE}Healthcheck Log (last 5 lines):${NC}"
if [[ -f /var/log/souqmatbakh/healthcheck.log ]]; then
    tail -n 5 /var/log/souqmatbakh/healthcheck.log || echo "No healthcheck logs yet"
else
    echo "No healthcheck log file found"
fi

# Summary
print_header "Verification Summary"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ All checks passed! Ops Pack is operational.${NC}"
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠ Some checks failed. Review the output above.${NC}"
    exit 1
fi
