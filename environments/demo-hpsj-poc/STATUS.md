# HPSJ Optum CES Demo — Deployment Status

**Last updated:** 2026-02-20
**Okta Org:** demo-hpsj-poc.okta.com
**AWS Account:** 357013128720 (us-east-2 for infra, us-east-1 for state)

---

## Completed

### Okta Resources (Terraform)
- [x] 77 demo users across 6 departments (from `hpsj_users.csv`)
- [x] 4 CES access groups: Enterprise Admin, Administrator, Claims Reviewer, System View Only
- [x] 6 department groups with auto-assignment rules (by `user.department`)
- [x] Group-to-app assignments for Generic DB Connector app (`0oav81kskg950Qm9w1d7`)
- [x] All group memberships (users → CES access groups)

### Generic DB Infrastructure (Terraform)
- [x] VPC (`10.5.0.0/16`) in us-east-2 with 2 subnets, IGW, route table
- [x] PostgreSQL 15 RDS (db.t3.micro, `okta_connector` database)
- [x] Security group restricted to VPC CIDR (not 0.0.0.0/0)
- [x] `publicly_accessible = false`
- [x] Credentials in Secrets Manager: `demo-hpsj-poc-use2-generic-db-credentials`

### Database Schema & Data
- [x] Schema applied (users, entitlements, user_entitlements, groups, user_groups, audit_log)
- [x] Views: `v_users_with_entitlements`, `v_active_entitlements`
- [x] Stored procedures: create_user, update_user, deactivate_user, assign/revoke_entitlement
- [x] HPSJ seed data loaded: 77 users, 4 CES roles, 10 groups, 154 group memberships

### OPC Agent Infrastructure (Terraform)
- [x] EC2 instance (RHEL 8, stock AMI bootstrap): `i-0a054f1edddfdd2a6`
- [x] Private IP: `10.5.1.121`
- [x] SSM accessible (psql installed)
- [x] Okta SWG security group attached (via `modules/okta-swg-security-group`)
- [x] IAM role with SSM permissions

### Reusable Module Created
- [x] `modules/okta-swg-security-group/` — creates SG from Okta managed prefix lists (mirrors Okta-SWG-All-US)

### Workflow Fixes
- [x] `tf-plan.yml` and `tf-apply.yml` — added `demo-hpsj-poc` to dropdown, fixed heredoc→echo for tfvars

---

## Remaining Tasks

### 1. Install & Configure OPC Connector (Manual)
The OPC agent EC2 is running but the Okta On-Prem Connector software is not yet installed.

- [ ] SSM into the OPC instance: `aws ssm start-session --target i-0a054f1edddfdd2a6 --region us-east-2`
- [ ] Download the OPC installer from Okta Admin UI → Settings → Downloads → On-Prem Provisioning
- [ ] Install the connector and register it with the `demo-hpsj-poc` Okta org
- [ ] Configure the JDBC connection to the PostgreSQL RDS:
  - Host: `demo-hpsj-poc-use2-generic-db.cfi2msw2o44f.us-east-2.rds.amazonaws.com`
  - Port: `5432`
  - Database: `okta_connector`
  - User: `oktaadmin`
  - Password: in Secrets Manager (`demo-hpsj-poc-use2-generic-db-credentials`)
  - JDBC driver: `postgresql-42.7.4.jar` (download URL in OPC terraform config)

### 2. Configure Generic DB Connector App in Okta (Manual)
- [ ] In Okta Admin UI → Applications → Optum CES (Generic DB Connector)
- [ ] Configure provisioning settings (To App / From App)
- [ ] Map user attributes between Okta profile and DB columns
- [ ] Test the import — verify users and entitlements appear in Okta
- [ ] Enable user import schedule if desired

### 3. Enable Entitlement Management (Manual)
- [ ] In Okta Admin UI → Applications → Optum CES → Governance tab
- [ ] Enable entitlement management for the app
- [ ] Verify the 4 CES entitlements (roles) are imported from the database
- [ ] Optionally create entitlement bundles for the 4 roles

### 4. Optional: Access Request & Approval Configuration
- [ ] Set up access request policies for CES roles
- [ ] Configure approval workflows (manager approval, IT approval, etc.)
- [ ] Add the app to the governance catalog
- [ ] Test end-to-end: user requests CES role → approval → provisioned in DB

### 5. Optional: Build a "Run SQL" Workflow
- [ ] Create `.github/workflows/run-sql.yml` for executing SQL against the database via SSM
- [ ] Useful for re-seeding data, running migrations, or verification queries

---

## Key Resources

| Resource | Value |
|----------|-------|
| Okta App ID | `0oav81kskg950Qm9w1d7` |
| RDS Endpoint | `demo-hpsj-poc-use2-generic-db.cfi2msw2o44f.us-east-2.rds.amazonaws.com` |
| OPC Instance ID | `i-0a054f1edddfdd2a6` |
| OPC Private IP | `10.5.1.121` |
| State Bucket | `okta-terraform-demo` (us-east-1) |
| Credentials Secret | `demo-hpsj-poc-use2-generic-db-credentials` (us-east-2) |
| VPC ID | See `terraform output` from generic-db stack |

## Terraform State Paths

| Stack | State Key |
|-------|-----------|
| Okta Resources | `Okta-GitOps/demo-hpsj-poc/terraform.tfstate` |
| Generic DB | `Okta-GitOps/demo-hpsj-poc/generic-db/terraform.tfstate` |
| OPC Agent | `Okta-GitOps/demo-hpsj-poc/opc-infrastructure/terraform.tfstate` |
