# HPSJ Optum CES — Generic DB Connector SQL Queries

This document contains all SQL queries needed to configure the Okta Generic Database Connector
for the HPSJ CES (Claims Edit System) demo environment.

---

## Connection Details

| Setting | Value |
|---------|-------|
| **JDBC URL** | `jdbc:postgresql://demo-hpsj-poc-use2-generic-db.cfi2msw2o44f.us-east-2.rds.amazonaws.com:5432/okta_connector` |
| **Username** | `oktaadmin` |
| **Password** | Stored in AWS Secrets Manager: `demo-hpsj-poc-use2-generic-db-credentials` (us-east-2) |
| **JDBC Driver** | PostgreSQL 42.7.4 (`postgresql-42.7.4.jar`) |
| **OPC Instance** | `i-0a054f1edddfdd2a6` (Private IP: `10.5.1.121`) |
| **Okta App ID** | `0oav81kskg950Qm9w1d7` |

---

## SCIM Attribute Mapping

| SCIM Attribute | DB Column | Notes |
|----------------|-----------|-------|
| `userName` | `username` | Unique login identifier |
| `externalId` | `user_id` | Unique external ID (e.g., `usr-001`) |
| `name.givenName` | `first_name` | |
| `name.familyName` | `last_name` | |
| `emails[0].value` | `email` | |
| `title` | `title` | |
| `department` | `department` | |
| `active` | `status` | Map `ACTIVE`→`true`, `INACTIVE`→`false` |
| `urn:okta:scim:...:Entitlement` | `entitlement_id` | Via `user_entitlements` join |

---

## SQL Queries for Connector Configuration

### Get All Users (Import)

```sql
SELECT
    u.user_id AS "id",
    u.username AS "userName",
    u.email AS "email",
    u.first_name AS "firstName",
    u.last_name AS "lastName",
    u.department AS "department",
    u.title AS "title",
    u.status AS "status",
    u.created_at AS "createdAt",
    u.updated_at AS "updatedAt"
FROM users u
WHERE u.status = 'ACTIVE'
ORDER BY u.user_id
```

### Get Specific User

```sql
SELECT
    u.user_id AS "id",
    u.username AS "userName",
    u.email AS "email",
    u.first_name AS "firstName",
    u.last_name AS "lastName",
    u.department AS "department",
    u.title AS "title",
    u.status AS "status",
    u.created_at AS "createdAt",
    u.updated_at AS "updatedAt"
FROM users u
WHERE u.user_id = ?
```

### Create User

```sql
INSERT INTO users (user_id, username, email, first_name, last_name, department, title, status)
VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE')
```

### Update User

> **CRITICAL**: This query MUST be configured even if you don't intend to push profile updates.
> Entitlement import from the Generic DB Connector **requires** "Provisioning to App" to be enabled
> AND the Update User SQL query to be set. Without this, Okta silently ignores entitlement data
> during import — `custom_object.complete: totalObjects: 0` in system logs.

```sql
UPDATE users
SET
    username = ?,
    email = ?,
    first_name = ?,
    last_name = ?,
    department = ?,
    title = ?,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = ?
```

### Deactivate User

```sql
UPDATE users
SET
    status = 'INACTIVE',
    deactivated_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = ?
```

---

## Entitlement Queries

### Import Entitlements (Get All Entitlements)

```sql
SELECT
    e.entitlement_id AS "id",
    e.name AS "displayName",
    e.description AS "description",
    e.category AS "type",
    e.risk_level AS "riskLevel"
FROM entitlements e
WHERE e.status = 'ACTIVE'
ORDER BY e.name
```

### Get User's Entitlements

```sql
SELECT
    e.entitlement_id AS "id",
    e.name AS "displayName",
    e.description AS "description",
    e.category AS "type"
FROM user_entitlements ue
JOIN entitlements e ON e.entitlement_id = ue.entitlement_id
WHERE ue.user_id = ?
  AND ue.status = 'ACTIVE'
```

### Assign Entitlement to User

```sql
INSERT INTO user_entitlements (user_id, entitlement_id, granted_by, status)
VALUES (?, ?, 'okta', 'ACTIVE')
ON CONFLICT (user_id, entitlement_id)
DO UPDATE SET status = 'ACTIVE', granted_at = CURRENT_TIMESTAMP, revoked_at = NULL
```

### Revoke Entitlement from User

```sql
UPDATE user_entitlements
SET
    status = 'REVOKED',
    revoked_at = CURRENT_TIMESTAMP,
    revoked_by = 'okta'
WHERE user_id = ?
  AND entitlement_id = ?
```

---

## Data Summary

| Entity | Count | Details |
|--------|-------|---------|
| **Users** | 77 | Across 6 departments |
| **Entitlements** | 4 | Enterprise Admin (8), Administrator (15), Claims Reviewer (31), System View Only (23) |
| **Groups** | 10 | 4 CES access + 6 department |
| **User-Entitlement Assignments** | 77 | 1:1 user-to-role |

### CES Roles (Entitlements)

| Entitlement ID | Name | Risk Level | Assigned Users |
|---------------|------|------------|----------------|
| `ces-enterprise-admin` | Enterprise Admin | CRITICAL | 8 |
| `ces-administrator` | CES Administrator | HIGH | 15 |
| `ces-claims-reviewer` | Claims Reviewer | MEDIUM | 31 |
| `ces-system-view-only` | System View Only | LOW | 23 |

---

## Configuration Checklist

1. **Install OPC Connector** on EC2 instance `i-0a054f1edddfdd2a6`
   ```bash
   aws ssm start-session --target i-0a054f1edddfdd2a6 --region us-east-2
   ```

2. **Configure JDBC connection** using the connection details above

3. **Enable "Provisioning to App"** in Okta Admin Console:
   - Applications → Optum CES → Provisioning tab → To App
   - Enable "Update User Attributes"
   - Set the Update User SQL query (see above)

4. **Enable "Provisioning from App"** (Import):
   - Applications → Optum CES → Provisioning tab → To Okta
   - Enable User Import

5. **Associate Import Inline Hook**:
   - Applications → Optum CES → Import tab
   - Select "Unique Username Generator" hook
   - This prevents username collisions during import

6. **Run Import**:
   - Applications → Optum CES → Import tab → Import Now
   - Verify 77 users appear with correct profiles
   - Verify 4 entitlements are discovered

7. **Enable Entitlement Management**:
   - Applications → Optum CES → Governance tab
   - Enable entitlement management
   - Verify 4 CES roles appear as entitlements

---

## Verification Queries

Run these on the database to verify data integrity:

```sql
-- Count summary
SELECT 'Users' AS entity, COUNT(*) AS total FROM users
UNION ALL
SELECT 'Entitlements', COUNT(*) FROM entitlements
UNION ALL
SELECT 'User-Entitlement Assignments', COUNT(*) FROM user_entitlements
UNION ALL
SELECT 'Groups', COUNT(*) FROM groups
UNION ALL
SELECT 'User-Group Memberships', COUNT(*) FROM user_groups;

-- Role distribution
SELECT e.name AS role, COUNT(ue.id) AS assigned_users
FROM entitlements e
LEFT JOIN user_entitlements ue ON e.entitlement_id = ue.entitlement_id
GROUP BY e.name
ORDER BY assigned_users DESC;
```
