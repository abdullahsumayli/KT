# Cloudflare WAF Configuration Guide

**Domain:** souqmatbakh.com  
**Environment:** Production  
**Stack:** Cloudflare Edge → Nginx → FastAPI  
**Last Updated:** 2025-12-14

---

## Overview

This guide provides step-by-step instructions for configuring Cloudflare Web Application Firewall (WAF) to protect souqmatbakh.com against common web attacks, bot traffic, and abuse patterns.

**Security Layers:**

1. **Cloudflare Edge** (This guide) - DDoS, WAF, Bot protection
2. **Nginx** - Rate limiting (20/s API, 5/m auth)
3. **FastAPI** - Application-level rate limiting (slowapi)

---

## Prerequisites

- ✅ Cloudflare account with souqmatbakh.com domain added
- ✅ DNS nameservers pointed to Cloudflare
- ✅ Cloudflare proxy enabled (orange cloud ☁️ on DNS records)
- ✅ SSL/TLS encryption mode set to "Full (Strict)"

---

## Configuration Steps

### Step 1: Enable Bot Fight Mode

**Purpose:** Block automated bot traffic while allowing legitimate bots (Google, Bing, etc.)

**Navigation Path:**

```
Dashboard → souqmatbakh.com → Security → Bots
```

**Configuration:**

1. Login to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select domain: **souqmatbakh.com**
3. Click **"Security"** in left sidebar
4. Click **"Bots"** tab
5. Locate **"Bot Fight Mode"** section
6. **Toggle ON** the switch
7. Enable settings:
   - ✅ **Definitely automated** - Block confirmed bots
   - ✅ **Verified bots** - Allow legitimate bots (Google, Bing, etc.)
8. Configuration auto-saves

**Expected Result:**

- Automated bot traffic receives challenge page
- Legitimate crawlers (Google, Bing) continue to access site
- DDoS bot attacks mitigated at edge

**Verification:**

```bash
# Test bot detection (should receive challenge)
curl -A "BadBot/1.0" https://souqmatbakh.com
```

---

### Step 2: Enable Cloudflare Managed Rules (OWASP)

**Purpose:** Protect against OWASP Top 10 vulnerabilities (SQLi, XSS, RCE, etc.)

**Navigation Path:**

```
Dashboard → souqmatbakh.com → Security → WAF → Managed rules
```

**Configuration:**

#### 2.1 Enable Cloudflare Managed Ruleset

1. Stay in **Security** section
2. Click **"WAF"** tab
3. Click **"Managed rules"** sub-tab
4. Locate **"Cloudflare Managed Ruleset"**
5. **Toggle ON** to enable
6. Ruleset activates immediately

#### 2.2 Enable OWASP Core Ruleset

1. Scroll to **"Cloudflare OWASP Core Ruleset"**
2. **Toggle ON** to enable
3. Click **"Configure"** button next to ruleset name
4. Set **Sensitivity Level**: **Medium**
   - Low: Fewer false positives, may miss attacks
   - **Medium**: ✅ Balanced (recommended for production)
   - High: Aggressive protection, potential false positives
5. Click **"Save"**

**Expected Result:**

- Protection against SQL injection attempts
- XSS attack mitigation
- Remote code execution (RCE) blocking
- Path traversal protection
- Other OWASP Top 10 threats blocked

**Verification:**

```bash
# Test SQLi detection (should be blocked)
curl "https://souqmatbakh.com/api/v1/products?id=1' OR '1'='1"

# Expected: 403 Forbidden or WAF challenge page
```

---

### Step 3: Configure Rate Limiting - Auth Endpoints

**Purpose:** Prevent brute force attacks on authentication endpoints

**Navigation Path:**

```
Dashboard → souqmatbakh.com → Security → WAF → Rate limiting rules
```

**Configuration:**

1. Stay in **Security → WAF** section
2. Click **"Rate limiting rules"** sub-tab
3. Click **"Create rule"** button
4. Fill in rule details:

**Rule Configuration:**

| Field                             | Value                                                     |
| --------------------------------- | --------------------------------------------------------- |
| **Rule name**                     | `Rate Limit - Auth Endpoints`                             |
| **When incoming requests match**  |                                                           |
| └ Field                           | URI Path                                                  |
| └ Operator                        | starts with                                               |
| └ Value                           | `/api/auth/`                                              |
| **Then take action**              |                                                           |
| └ Action                          | Block                                                     |
| └ Response code                   | 429                                                       |
| └ Response body                   | `{"error": "Too many requests. Please try again later."}` |
| **For**                           |                                                           |
| └ Requests                        | 10                                                        |
| └ Period                          | 1 minute                                                  |
| └ Counting method                 | Fixed window                                              |
| **With the same characteristics** |                                                           |
| └ Characteristics                 | IP Address                                                |
| **Request aggregation**           | Use visitor identifier                                    |

5. Click **"Deploy"** button

**Expected Result:**

- Authentication endpoints limited to 10 requests per minute per IP
- Brute force attacks automatically blocked
- Legitimate users unaffected (10 attempts sufficient)
- Exceeding limit returns HTTP 429 with JSON error

**Rate Limiting Hierarchy:**

```
Cloudflare: 10 req/min  ← First line of defense
    ↓ (if passed)
Nginx: 5 req/min        ← Second layer
    ↓ (if passed)
FastAPI: 3-5 req/min    ← Application layer
```

---

### Step 4: Configure Rate Limiting - General Traffic

**Purpose:** Protect against DDoS and aggressive scraping while maintaining user experience

**Navigation Path:**

```
Dashboard → souqmatbakh.com → Security → WAF → Rate limiting rules
```

**Configuration:**

1. Click **"Create rule"** button (in Rate limiting rules)
2. Fill in rule details:

**Rule Configuration:**

| Field                             | Value                                             |
| --------------------------------- | ------------------------------------------------- |
| **Rule name**                     | `Rate Limit - General Traffic`                    |
| **When incoming requests match**  |                                                   |
| └ Field                           | URI Path                                          |
| └ Operator                        | matches                                           |
| └ Value                           | `/*` (or leave empty for "All incoming requests") |
| **Then take action**              |                                                   |
| └ Action                          | Managed Challenge                                 |
| └ (Note)                          | Non-interactive challenge, invisible to humans    |
| **For**                           |                                                   |
| └ Requests                        | 300                                               |
| └ Period                          | 1 minute                                          |
| └ Counting method                 | Fixed window                                      |
| **With the same characteristics** |                                                   |
| └ Characteristics                 | IP Address                                        |
| **Request aggregation**           | Use visitor identifier                            |

3. Click **"Deploy"** button

**Expected Result:**

- General traffic limited to 300 requests per minute per IP
- Managed Challenge served to excessive requesters
- Legitimate users unaffected (challenge invisible to humans)
- Aggressive scrapers and DDoS attacks mitigated

**Challenge Behavior:**

- **Humans**: Pass automatically (JavaScript verification)
- **Legitimate bots**: Pass if verified
- **Malicious bots**: Blocked or challenged repeatedly

---

### Step 5: Set Security Level to Medium

**Purpose:** Balance security and user experience with moderate threat protection

**Navigation Path:**

```
Dashboard → souqmatbakh.com → Security → Settings
```

**Configuration:**

1. Click **"Security"** in left sidebar
2. Click **"Settings"** tab
3. Scroll to **"Security Level"** section
4. Select **"Medium"**
   - **Essentially Off**: No challenges (not recommended)
   - **Low**: Only highest threats challenged
   - **Medium**: ✅ Moderate threat score triggers challenge (recommended)
   - **High**: More visitors challenged (may impact UX)
   - **I'm Under Attack**: Maximum protection (emergency mode)
5. Changes auto-save (no Save button)

**Expected Result:**

- Known malicious IPs challenged automatically
- Moderate threat scores trigger verification
- Legitimate users rarely see challenges
- Balanced protection without false positives

---

## Verification & Testing

### 1. Verify Configuration

#### Check Rate Limiting Rules

**Navigation:** Security → WAF → Rate limiting rules

**Expected State:**

- ✅ `Rate Limit - Auth Endpoints` (10/min, Block, Active)
- ✅ `Rate Limit - General Traffic` (300/min, Managed Challenge, Active)

#### Check Managed Rules

**Navigation:** Security → WAF → Managed rules

**Expected State:**

- ✅ Cloudflare Managed Ruleset: **Enabled**
- ✅ Cloudflare OWASP Core Ruleset: **Enabled** (Sensitivity: Medium)

#### Check Bot Protection

**Navigation:** Security → Bots

**Expected State:**

- ✅ Bot Fight Mode: **Enabled**
- ✅ Verified bots: **Allowed**

#### Check Security Level

**Navigation:** Security → Settings

**Expected State:**

- ✅ Security Level: **Medium**

---

### 2. Test Auth Rate Limiting

**Test Command:**

```bash
# Test auth endpoint rate limiting (should block after 10 requests)
for i in {1..15}; do
  echo "Request $i:"
  curl -w "HTTP %{http_code}\n" -s -o /dev/null \
    -X POST https://souqmatbakh.com/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"test123"}'
  sleep 0.5
done
```

**Expected Output:**

```
Request 1: HTTP 401  (or 422 - invalid credentials)
Request 2: HTTP 401
...
Request 10: HTTP 401
Request 11: HTTP 429  ← Rate limit triggered
Request 12: HTTP 429
Request 13: HTTP 429
Request 14: HTTP 429
Request 15: HTTP 429
```

**Success Criteria:**

- ✅ First 10 requests processed (401/422 from backend)
- ✅ Requests 11-15 blocked with HTTP 429
- ✅ Rate limit resets after 1 minute

---

### 3. Test General Rate Limiting

**Test Command:**

```bash
# Test general traffic rate limiting (should challenge after 300)
for i in {1..350}; do
  curl -w "%{http_code}\n" -s -o /dev/null https://souqmatbakh.com/
  sleep 0.1
done | sort | uniq -c
```

**Expected Output:**

```
300 200  ← Normal traffic
 50 403  ← Managed Challenge triggered (or challenge page HTML)
```

**Success Criteria:**

- ✅ First 300 requests return HTTP 200
- ✅ Remaining 50 requests receive challenge
- ✅ Rate limit resets after 1 minute

---

### 4. Test OWASP Protection

**Test Command:**

```bash
# Test SQL injection protection
curl -i "https://souqmatbakh.com/api/v1/products?id=1' OR '1'='1"

# Test XSS protection
curl -i "https://souqmatbakh.com/api/v1/search?q=<script>alert('xss')</script>"

# Test path traversal protection
curl -i "https://souqmatbakh.com/api/v1/../../../etc/passwd"
```

**Expected Output:**

```
HTTP/1.1 403 Forbidden
...
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<center>cloudflare</center>
</body>
</html>
```

**Success Criteria:**

- ✅ All malicious requests blocked with HTTP 403
- ✅ Cloudflare in response body/headers
- ✅ Requests never reach backend server

---

### 5. Monitor Security Events

**Navigation:** Security → Overview

**Dashboard Metrics:**

- **Threats Mitigated**: Total blocked requests
- **Rate Limiting Events**: Triggered rate limit rules
- **Bot Traffic**: Automated vs legitimate bot traffic
- **OWASP Rule Triggers**: WAF rule activations
- **Challenge Solve Rate**: Percentage of challenges passed

**View Detailed Events:**

1. Go to **Security → Events**
2. Filter by:
   - Action: Block, Challenge, Managed Challenge
   - Rule: Select specific rate limit or WAF rule
   - Time Range: Last 24 hours / 7 days / 30 days
3. Review:
   - Source IP addresses
   - User agents
   - Request paths
   - Triggered rules

---

## Multi-Layer Rate Limiting Strategy

### Current Protection Layers

| Layer             | Location    | Auth Limit | API Limit | Action            | Purpose                   |
| ----------------- | ----------- | ---------- | --------- | ----------------- | ------------------------- |
| **1. Cloudflare** | Edge        | 10/min     | 300/min   | Block / Challenge | DDoS, distributed attacks |
| **2. Nginx**      | Server      | 5/min      | 20/sec    | HTTP 429          | Server protection         |
| **3. FastAPI**    | Application | 3-5/min    | -         | HTTP 429          | Business logic protection |

### Recommendation: Consolidate Layers

**Current State:** Triple rate limiting may be excessive for legitimate users

**Option A - Keep All Layers** (Maximum Security)

```
✅ Pros: Defense in depth, redundancy
❌ Cons: Complex troubleshooting, potential false positives
```

**Option B - Cloudflare + Nginx** (Recommended)

```
✅ Pros: Edge + server protection, simpler debugging
✅ Action: Disable FastAPI slowapi decorators
```

**Option C - Cloudflare Only** (Simplified)

```
✅ Pros: Simplest configuration, all protection at edge
❌ Cons: No protection if Cloudflare bypassed
⚠️ Not recommended for production
```

**Recommended Configuration:**

- Keep **Cloudflare** for DDoS and distributed attacks
- Keep **Nginx** for server-level protection
- Consider **disabling FastAPI slowapi** to reduce complexity

---

## IP Whitelisting (Trusted Sources)

### When to Whitelist

- Monitoring services (UptimeRobot, Pingdom, etc.)
- CI/CD pipelines (GitHub Actions, GitLab CI)
- Partner API integrations
- Internal office/VPN IPs
- Development team IPs (optional)

### How to Whitelist IPs

**Navigation:** Security → WAF → Tools → IP Access Rules

**Steps:**

1. Go to **Security → WAF**
2. Click **"Tools"** tab
3. Click **"IP Access Rules"**
4. Click **"Add rule"**
5. Configure:
   - **IP/IP Range**: Enter IP address (e.g., `203.0.113.0`)
   - **Action**: Select **"Allow"**
   - **Zone**: Select **"This website"** (souqmatbakh.com)
   - **Note**: Add description (e.g., "UptimeRobot Monitor")
6. Click **"Add"**

**Whitelisted IPs bypass:**

- ✅ Rate limiting rules
- ✅ WAF challenges
- ✅ Bot Fight Mode
- ⚠️ Still subject to OWASP rules (security not bypassed)

---

## Troubleshooting

### Issue: Legitimate Users Blocked

**Symptoms:**

- Users report 403 Forbidden errors
- Valid requests blocked by WAF
- High false positive rate

**Solutions:**

1. **Lower OWASP Sensitivity**

   - Navigate: Security → WAF → Managed rules
   - Click "Configure" on OWASP ruleset
   - Change sensitivity: Medium → **Low**
   - Save changes

2. **Increase Rate Limits**

   - Navigate: Security → WAF → Rate limiting rules
   - Edit rule: Click rule name
   - Increase limits:
     - Auth: 10/min → **15/min** or **20/min**
     - General: 300/min → **500/min**
   - Deploy changes

3. **Add User IPs to Allowlist**

   - Navigate: Security → WAF → Tools → IP Access Rules
   - Add user IP with "Allow" action

4. **Review Security Events**
   - Navigate: Security → Events
   - Filter by "Block" action
   - Identify false positive patterns
   - Create exception rules if needed

---

### Issue: Too Many 429 Errors

**Symptoms:**

- Mobile app users frequently rate-limited
- API clients receiving 429 responses
- Legitimate traffic blocked

**Solutions:**

1. **Adjust Rate Limits**

   ```
   Current: 10/min auth, 300/min general
   Increased: 20/min auth, 500/min general
   ```

2. **Change Action Type**

   - Auth endpoints: Block → **Managed Challenge**
   - Allows humans to proceed, blocks bots

3. **Implement API Key System**

   - Issue API keys to trusted clients
   - Whitelist API key header in rate limiting rules
   - Higher limits for authenticated API requests

4. **Use Different Rate Limit Characteristics**
   - Current: IP Address
   - Alternative: IP + User Agent
   - Alternative: IP + Request Header (e.g., API key)

---

### Issue: API Clients Failing Challenges

**Symptoms:**

- Mobile app cannot pass Managed Challenge
- API integrations fail with challenge page
- Automated tests blocked

**Solutions:**

1. **Whitelist API Client User-Agents**

   - Navigate: Security → WAF → Rate limiting rules
   - Edit rule → Add exception:

   ```
   Exclude when:
   - Field: User Agent
   - Operator: equals
   - Value: "YourApp/1.0" (your app's user agent)
   ```

2. **Use IP-Based Allowlist for API Clients**

   - Get client IP ranges
   - Add to IP Access Rules with "Allow" action
   - API clients bypass challenges

3. **Issue API Tokens**

   - Implement custom header: `X-API-Key`
   - Create rate limit exception for requests with valid API key
   - Higher limits for authenticated requests

4. **Adjust Challenge Type**
   - Navigate: Security → Settings
   - Change Challenge Passage: 30 minutes → **1 day**
   - Reduces challenge frequency for same client

---

### Issue: Bot Traffic Still Getting Through

**Symptoms:**

- Excessive bot traffic in analytics
- Scraping attempts successful
- Bot Fight Mode ineffective

**Solutions:**

1. **Upgrade Bot Protection** (Requires Pro/Business Plan)

   - Navigate: Security → Bots
   - Upgrade to **Super Bot Fight Mode**
   - More advanced bot detection
   - Machine learning-based identification

2. **Create Custom Bot Rules**

   - Navigate: Security → WAF → Custom rules
   - Create rule to block suspicious patterns:

   ```
   Field: User Agent
   Operator: contains
   Value: "python-requests" OR "curl" OR "wget"
   Action: Block
   ```

3. **Enable JavaScript Challenge**

   - Navigate: Security → Settings
   - Set Security Level: Medium → **High**
   - More aggressive bot detection

4. **Implement Token-Based Access**
   - Add CSRF tokens to forms
   - Require JavaScript execution for API access
   - Rotate tokens frequently

---

## Monitoring & Maintenance

### Daily Monitoring

**Dashboard Checks** (5 minutes):

1. Navigate: **Security → Overview**
2. Review last 24 hours:
   - ✅ Threats mitigated (should be > 0 if attacks occur)
   - ✅ Rate limiting events (monitor for spikes)
   - ✅ Bot traffic percentage (typical: 10-30%)
   - ⚠️ Challenge solve rate (should be > 90% for legitimate traffic)

**Alert on:**

- Sudden spike in blocked requests (potential attack)
- Challenge solve rate < 80% (possible false positives)
- Zero threats mitigated for extended period (WAF misconfiguration?)

---

### Weekly Reviews

**Security Events Analysis** (15 minutes):

1. Navigate: **Security → Events**
2. Filter: Last 7 days
3. Review:
   - Top blocked IPs (check for persistent attackers)
   - Most triggered rules (identify common attack patterns)
   - False positives (legitimate requests blocked)
   - User agent patterns (bot identification)

**Actions:**

- Blacklist persistent attacker IPs (if outside Cloudflare)
- Adjust OWASP sensitivity if false positives detected
- Update rate limits based on traffic patterns
- Document attack patterns and responses

---

### Monthly Tasks

**Configuration Review** (30 minutes):

1. **Update Rulesets**:

   - Navigate: Security → WAF → Managed rules
   - Check for "Update available" badges
   - Review changelog for new rules
   - Deploy updates after testing

2. **Analyze Traffic Patterns**:

   - Navigate: Analytics → Traffic
   - Review: Requests per day, unique visitors, bandwidth
   - Compare: Month-over-month growth
   - Adjust: Rate limits based on growth

3. **Review Bot Detection**:

   - Navigate: Security → Bots
   - Analyze: Bot traffic percentage, blocked bots
   - Evaluate: Bot Fight Mode effectiveness
   - Consider: Upgrade to Super Bot Fight Mode if needed

4. **Audit IP Access Rules**:

   - Navigate: Security → WAF → Tools → IP Access Rules
   - Review: All whitelisted IPs
   - Remove: Outdated or unused entries
   - Document: Reason for each whitelist

5. **Performance Impact Assessment**:
   - Check: Average response time (Analytics → Performance)
   - Verify: Cloudflare caching effectiveness
   - Optimize: Cache rules and page rules if needed

---

### Quarterly Security Audit

**Comprehensive Review** (1-2 hours):

1. **Penetration Testing**:

   - Run OWASP ZAP or Burp Suite against domain
   - Test SQLi, XSS, CSRF, authentication bypass
   - Verify WAF blocks all attack vectors
   - Document findings and remediation

2. **Rate Limit Effectiveness**:

   - Simulate brute force attack (controlled environment)
   - Verify rate limits trigger appropriately
   - Test bypass attempts (header manipulation, IP rotation)
   - Adjust limits based on results

3. **Bot Detection Review**:

   - Analyze bot traffic trends (last 3 months)
   - Identify new bot patterns
   - Update bot detection rules
   - Consider ML-based solutions if needed

4. **Documentation Update**:

   - Review this guide for accuracy
   - Update configuration values if changed
   - Add new troubleshooting scenarios encountered
   - Document lessons learned

5. **Compliance Check**:
   - Verify GDPR compliance (if applicable)
   - Review data retention policies
   - Ensure logging meets requirements
   - Update privacy policy if needed

---

## Advanced Configuration

### Custom WAF Rules

**Example: Block Specific Countries**

```
Navigate: Security → WAF → Custom rules → Create rule

Rule name: Block Country X
When incoming requests match:
- Field: Country
- Operator: equals
- Value: XX (country code)

Then take action:
- Action: Block
```

**Example: Allow Only Specific Paths for API**

```
Rule name: API Path Whitelist
When incoming requests match:
- Field: URI Path
- Operator: starts with
- Value: /api/
- AND
- Field: URI Path
- Operator: not equals
- Value: /api/v1/

Then take action:
- Action: Block
```

---

### Cloudflare Page Rules (Performance)

**Navigation:** Rules → Page Rules

**Example: Cache API Responses** (Use with caution)

```
URL pattern: souqmatbakh.com/api/v1/products*

Settings:
- Cache Level: Cache Everything
- Edge Cache TTL: 5 minutes
- Browser Cache TTL: 2 minutes
```

**Example: Bypass Cache for Auth**

```
URL pattern: souqmatbakh.com/api/v1/auth/*

Settings:
- Cache Level: Bypass
- Security Level: High (more protection on auth)
```

---

## Security Best Practices

### SSL/TLS Configuration

**Recommended Settings:**

1. Navigate: **SSL/TLS → Overview**
2. Set **Encryption Mode**: **Full (Strict)**

   - Ensures end-to-end encryption
   - Validates origin certificate

3. Navigate: **SSL/TLS → Edge Certificates**
4. Enable:
   - ✅ **Always Use HTTPS** (redirect HTTP → HTTPS)
   - ✅ **HTTP Strict Transport Security (HSTS)**
     - Max Age: 6 months (15768000 seconds)
     - Include subdomains: Yes
     - Preload: Yes (after testing)
   - ✅ **Minimum TLS Version**: TLS 1.2
   - ✅ **Opportunistic Encryption**: Enabled
   - ✅ **TLS 1.3**: Enabled

---

### HTTP Headers Security

**Recommended Headers:**

```nginx
# Already configured in Nginx, but verify Cloudflare preserves:
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

**Cloudflare Transform Rules** (Add headers if missing):

1. Navigate: **Rules → Transform Rules → Modify Response Header**
2. Create rule to add security headers
3. Apply to all requests

---

### DDoS Protection

**Cloudflare Automatic Protection:**

- ✅ L3/L4 DDoS mitigation (network layer)
- ✅ L7 DDoS mitigation (application layer)
- ✅ Automatic detection and mitigation
- ⚠️ No configuration needed (always on)

**Manual Override (Emergency):**

1. Navigate: **Security → Settings**
2. Set **Security Level**: **I'm Under Attack**
3. All visitors receive JavaScript challenge
4. Revert to **Medium** after attack subsides

---

## Cost Considerations

### Free Plan Limitations

- ✅ Bot Fight Mode: Basic (sufficient for most cases)
- ✅ WAF Managed Rules: Limited ruleset
- ✅ Rate Limiting: 1 rule (upgrade needed for multiple rules)
- ⚠️ Some features require Pro/Business plan

### Pro Plan Benefits ($20/month)

- ✅ More rate limiting rules (up to 10)
- ✅ Advanced bot detection
- ✅ WAF custom rules (5 rules)
- ✅ Image optimization
- ✅ Mobile redirect

### Business Plan Benefits ($200/month)

- ✅ Unlimited rate limiting rules
- ✅ Super Bot Fight Mode (ML-based)
- ✅ WAF custom rules (25 rules)
- ✅ Guaranteed 100% uptime SLA
- ✅ Priority support

**Recommendation for souqmatbakh.com:**

- Start with **Free Plan** (sufficient for launch)
- Upgrade to **Pro** when traffic > 10k visitors/day
- Upgrade to **Business** when revenue justifies cost and require SLA

---

## Additional Resources

### Official Documentation

- [Cloudflare WAF](https://developers.cloudflare.com/waf/)
- [Rate Limiting Rules](https://developers.cloudflare.com/waf/rate-limiting-rules/)
- [Bot Fight Mode](https://developers.cloudflare.com/bots/get-started/free/)
- [OWASP Core Ruleset](https://developers.cloudflare.com/waf/managed-rules/reference/owasp-core-ruleset/)

### Security Testing Tools

- [OWASP ZAP](https://www.zaproxy.org/) - Web application security scanner
- [Burp Suite](https://portswigger.net/burp) - Security testing toolkit
- [SQLmap](https://sqlmap.org/) - SQL injection testing tool
- [Cloudflare Radar](https://radar.cloudflare.com/) - Internet traffic insights

### Related Documentation

- [SECURITY_AUDIT_REPORT.md](SECURITY_AUDIT_REPORT.md) - Comprehensive security audit
- [RATE_LIMITING_TEST_RESULTS.md](RATE_LIMITING_TEST_RESULTS.md) - Nginx rate limiting test results
- [deploy/README.md](deploy/README.md) - Deployment and configuration guide

---

## Support & Escalation

### Issue Severity Levels

**Critical (Response: Immediate)**

- Site completely down
- Active DDoS attack
- Data breach detected
- All requests blocked by WAF

**High (Response: < 4 hours)**

- Significant false positives (> 10% legitimate traffic blocked)
- Rate limiting too aggressive (users complaining)
- OWASP rules blocking critical functionality

**Medium (Response: < 24 hours)**

- Bot traffic increasing significantly
- Performance degradation
- Configuration optimization needed

**Low (Response: < 72 hours)**

- Documentation updates
- Fine-tuning rate limits
- Analytics review

### Escalation Path

1. **First**: Check Cloudflare Status (https://www.cloudflarestatus.com/)
2. **Second**: Review Security Events for root cause
3. **Third**: Adjust configuration (lower sensitivity, increase limits)
4. **Fourth**: Contact Cloudflare Support (if on paid plan)
5. **Last Resort**: Temporarily disable WAF rules (emergency only)

---

## Changelog

### 2025-12-14 - Initial Configuration

- ✅ Bot Fight Mode enabled
- ✅ OWASP Core Ruleset enabled (Sensitivity: Medium)
- ✅ Rate limiting configured (Auth: 10/min, General: 300/min)
- ✅ Security Level set to Medium
- ✅ Documentation created

### Future Updates

- [ ] Enable Super Bot Fight Mode (when upgraded to Pro/Business)
- [ ] Configure custom WAF rules for specific threats
- [ ] Implement API token-based rate limiting exceptions
- [ ] Enable Cloudflare Access for admin panel protection

---

**Document Version:** 1.0  
**Author:** DevOps Team  
**Review Date:** 2025-12-14  
**Next Review:** 2026-01-14 (monthly)
