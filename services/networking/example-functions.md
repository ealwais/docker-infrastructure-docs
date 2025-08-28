# N8N Function Node Examples for AdGuard DNS Management

## Add DNS Entry

```javascript
// Input: { domain: "service.alwais.org", ip: "192.168.1.100" }

const domain = $input.item.json.domain;
const ip = $input.item.json.ip;
const adguardUrl = 'http://adguard-home:3000';

try {
    const response = await $http.request({
        method: 'POST',
        url: `${adguardUrl}/control/rewrite/add`,
        body: {
            domain: domain,
            answer: ip
        },
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    return {
        json: {
            success: true,
            domain: domain,
            ip: ip,
            message: 'DNS entry added successfully'
        }
    };
} catch (error) {
    return {
        json: {
            success: false,
            error: error.message
        }
    };
}
```

## Update DNS Entry with Old IP Check

```javascript
// Input: { domain: "service.alwais.org", newIp: "192.168.1.101" }

const domain = $input.item.json.domain;
const newIp = $input.item.json.newIp;
const adguardUrl = 'http://adguard-home:3000';

try {
    // First, get the current DNS entries
    const listResponse = await $http.request({
        method: 'GET',
        url: `${adguardUrl}/control/rewrite/list`,
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    // Find the existing entry
    const existingEntry = listResponse.body.find(entry => entry.domain === domain);
    
    if (!existingEntry) {
        // Domain doesn't exist, add it
        await $http.request({
            method: 'POST',
            url: `${adguardUrl}/control/rewrite/add`,
            body: {
                domain: domain,
                answer: newIp
            },
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        return {
            json: {
                success: true,
                action: 'added',
                domain: domain,
                ip: newIp
            }
        };
    } else if (existingEntry.answer !== newIp) {
        // Domain exists with different IP, update it
        // First delete the old entry
        await $http.request({
            method: 'POST',
            url: `${adguardUrl}/control/rewrite/delete`,
            body: {
                domain: domain,
                answer: existingEntry.answer
            },
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        // Then add the new entry
        await $http.request({
            method: 'POST',
            url: `${adguardUrl}/control/rewrite/add`,
            body: {
                domain: domain,
                answer: newIp
            },
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        return {
            json: {
                success: true,
                action: 'updated',
                domain: domain,
                oldIp: existingEntry.answer,
                newIp: newIp
            }
        };
    } else {
        // Domain exists with same IP, no change needed
        return {
            json: {
                success: true,
                action: 'no_change',
                domain: domain,
                ip: newIp,
                message: 'DNS entry already exists with the same IP'
            }
        };
    }
} catch (error) {
    return {
        json: {
            success: false,
            error: error.message
        }
    };
}
```

## Batch Import DNS Entries

```javascript
// Input: { entries: [{ domain: "service1.alwais.org", ip: "192.168.1.100" }, ...] }

const entries = $input.item.json.entries;
const adguardUrl = 'http://adguard-home:3000';
const results = [];

for (const entry of entries) {
    try {
        await $http.request({
            method: 'POST',
            url: `${adguardUrl}/control/rewrite/add`,
            body: {
                domain: entry.domain,
                answer: entry.ip
            },
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        results.push({
            domain: entry.domain,
            ip: entry.ip,
            success: true
        });
    } catch (error) {
        results.push({
            domain: entry.domain,
            ip: entry.ip,
            success: false,
            error: error.message
        });
    }
}

const successful = results.filter(r => r.success).length;
const failed = results.filter(r => !r.success).length;

return {
    json: {
        total: entries.length,
        successful: successful,
        failed: failed,
        results: results
    }
};
```

## Clean Up Stale DNS Entries

```javascript
// Input: { ipPrefix: "192.168.1." }

const ipPrefix = $input.item.json.ipPrefix || '192.168.1.';
const adguardUrl = 'http://adguard-home:3000';

try {
    // Get all DNS entries
    const listResponse = await $http.request({
        method: 'GET',
        url: `${adguardUrl}/control/rewrite/list`,
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    const entries = listResponse.body;
    const toRemove = entries.filter(entry => entry.answer.startsWith(ipPrefix));
    const removed = [];
    
    for (const entry of toRemove) {
        try {
            await $http.request({
                method: 'POST',
                url: `${adguardUrl}/control/rewrite/delete`,
                body: {
                    domain: entry.domain,
                    answer: entry.answer
                },
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            removed.push({
                domain: entry.domain,
                ip: entry.answer,
                success: true
            });
        } catch (error) {
            removed.push({
                domain: entry.domain,
                ip: entry.answer,
                success: false,
                error: error.message
            });
        }
    }
    
    return {
        json: {
            total_entries: entries.length,
            matching_prefix: toRemove.length,
            removed: removed.filter(r => r.success).length,
            failed: removed.filter(r => !r.success).length,
            details: removed
        }
    };
} catch (error) {
    return {
        json: {
            success: false,
            error: error.message
        }
    };
}
```

## Check AdGuard Health

```javascript
// No input required

const adguardUrl = 'http://adguard-home:3000';

try {
    const statusResponse = await $http.request({
        method: 'GET',
        url: `${adguardUrl}/control/status`,
        headers: {
            'Content-Type': 'application/json'
        },
        timeout: 5000
    });
    
    const dnsResponse = await $http.request({
        method: 'GET',
        url: `${adguardUrl}/control/dns_info`,
        headers: {
            'Content-Type': 'application/json'
        }
    });
    
    return {
        json: {
            healthy: true,
            status: {
                running: statusResponse.body.running,
                version: statusResponse.body.version,
                dns_port: statusResponse.body.dns_port,
                uptime_seconds: statusResponse.body.uptime
            },
            dns_config: {
                upstream_dns: dnsResponse.body.upstream_dns,
                bootstrap_dns: dnsResponse.body.bootstrap_dns,
                protection_enabled: dnsResponse.body.protection_enabled,
                ratelimit: dnsResponse.body.ratelimit
            }
        }
    };
} catch (error) {
    return {
        json: {
            healthy: false,
            error: error.message
        }
    };
}
```