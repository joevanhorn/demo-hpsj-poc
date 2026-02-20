-- ==============================================================================
-- HPSJ OPTUM CES - DATABASE SEED
-- ==============================================================================
-- Populates the Generic DB Connector schema with HPSJ-specific data:
--   - 4 CES entitlements (application roles)
--   - 77 HPSJ users across 6 departments
--   - User-to-entitlement assignments matching the RBAC matrix
--
-- Prerequisite: Run schema.sql first to create tables/functions.
-- ==============================================================================

BEGIN;

-- ==============================================================================
-- CLEAN EXISTING SAMPLE DATA
-- ==============================================================================

TRUNCATE user_entitlements, user_groups, users, entitlements, groups CASCADE;

-- ==============================================================================
-- ENTITLEMENTS — Optum CES Application Roles
-- ==============================================================================

INSERT INTO entitlements (entitlement_id, name, description, category, risk_level) VALUES
(
  'ces-enterprise-admin',
  'Enterprise Admin',
  'Full enterprise configuration, claims management, rules, reports, and code repository management. '
  'Privileges: Configure enterprise, view claims and trace, edit test/live claims, delete claims, '
  'manage claim data, manage code repository, view/manage reports, manage rules/rulesets/trace.',
  'Role',
  'CRITICAL'
),
(
  'ces-administrator',
  'CES Administrator',
  'System-level administration including user/role management, KnowledgeBase loading, DDR, and audit logs. '
  'Privileges: Configure global settings, load KB, load LCD carriers, manage enterprises, manage roles, '
  'manage users, purge claims, view audit log, manage custom DDR, view/manage system-level reports.',
  'Role',
  'HIGH'
),
(
  'ces-claims-reviewer',
  'Claims Reviewer',
  'View-only access to claims data with PHI. '
  'Privileges: View claims and trace — view claim data with PHI (browse claims and claim history search).',
  'Role',
  'MEDIUM'
),
(
  'ces-system-view-only',
  'System View Only',
  'Read-only system-level access with no PHI exposure. '
  'Privileges: View only.',
  'Role',
  'LOW'
);

-- ==============================================================================
-- GROUPS — CES Access Groups + Department Groups
-- ==============================================================================

INSERT INTO groups (group_id, name, description, group_type) VALUES
('grp-ces-enterprise-admin', 'CES-Enterprise-Admin',    'Optum CES Enterprise Admin access group', 'STANDARD'),
('grp-ces-administrator',    'CES-Administrator',       'Optum CES System Administrator access group', 'STANDARD'),
('grp-ces-claims-reviewer',  'CES-Claims-Reviewer',     'Optum CES Claims Reviewer access group', 'STANDARD'),
('grp-ces-system-view-only', 'CES-System-View-Only',    'Optum CES System View Only access group', 'STANDARD'),
('grp-dept-claims',          'HPSJ-Claims',             'HPSJ Claims Department', 'STANDARD'),
('grp-dept-configuration',   'HPSJ-Configuration',      'HPSJ Configuration Department', 'STANDARD'),
('grp-dept-is',              'HPSJ-IS',                 'HPSJ Information Systems Department', 'STANDARD'),
('grp-dept-cmme',            'HPSJ-CMME',               'HPSJ Care Management / Medical Economics', 'STANDARD'),
('grp-dept-pharmacy',        'HPSJ-Pharmacy',           'HPSJ Pharmacy Department', 'STANDARD'),
('grp-dept-service-delivery','HPSJ-Service-Delivery',   'HPSJ Service Delivery Department', 'STANDARD');

-- ==============================================================================
-- USERS — 77 HPSJ employees
-- ==============================================================================

INSERT INTO users (user_id, username, email, first_name, last_name, department, title, status) VALUES
-- Enterprise Admin (8)
('usr-001', 'maria.santos',       'maria.santos@hpsj.example.com',       'Maria',     'Santos',     'Claims',        'Director of Claims', 'ACTIVE'),
('usr-002', 'david.chen',         'david.chen@hpsj.example.com',         'David',     'Chen',       'Claims',        'Manager of Claims Processing', 'ACTIVE'),
('usr-003', 'patricia.williams',  'patricia.williams@hpsj.example.com',  'Patricia',  'Williams',   'Configuration', 'Director of Configuration', 'ACTIVE'),
('usr-004', 'robert.taylor',      'robert.taylor@hpsj.example.com',      'Robert',    'Taylor',     'Configuration', 'Manager of Configuration', 'ACTIVE'),
('usr-005', 'james.wilson',       'james.wilson@hpsj.example.com',       'James',     'Wilson',     'IS',            'Director of Technology Operations', 'ACTIVE'),
('usr-006', 'sarah.johnson',      'sarah.johnson@hpsj.example.com',      'Sarah',     'Johnson',    'IS',            'Director of Business Intelligence', 'ACTIVE'),
('usr-007', 'michael.brown',      'michael.brown@hpsj.example.com',      'Michael',   'Brown',      'IS',            'Enterprise Architect', 'ACTIVE'),
('usr-008', 'linda.martinez',     'linda.martinez@hpsj.example.com',     'Linda',     'Martinez',   'Claims',        'Manager of Provider Disputes', 'ACTIVE'),
-- CES Administrator (15)
('usr-009', 'kevin.nguyen',       'kevin.nguyen@hpsj.example.com',       'Kevin',     'Nguyen',     'IS',            'Senior Systems Administrator', 'ACTIVE'),
('usr-010', 'jennifer.lee',       'jennifer.lee@hpsj.example.com',       'Jennifer',  'Lee',        'IS',            'Database Administrator Senior', 'ACTIVE'),
('usr-011', 'thomas.garcia',      'thomas.garcia@hpsj.example.com',      'Thomas',    'Garcia',     'IS',            'DevOps Engineer Lead', 'ACTIVE'),
('usr-012', 'amanda.clark',       'amanda.clark@hpsj.example.com',       'Amanda',    'Clark',      'IS',            'Senior DevOps Engineer', 'ACTIVE'),
('usr-013', 'christopher.lewis',  'christopher.lewis@hpsj.example.com',  'Christopher','Lewis',     'IS',            'Senior Information Security Analyst', 'ACTIVE'),
('usr-014', 'jessica.robinson',   'jessica.robinson@hpsj.example.com',   'Jessica',   'Robinson',   'IS',            'Security Analyst Associate', 'ACTIVE'),
('usr-015', 'daniel.walker',      'daniel.walker@hpsj.example.com',      'Daniel',    'Walker',     'IS',            'Systems Administrator Senior', 'ACTIVE'),
('usr-016', 'emily.hall',         'emily.hall@hpsj.example.com',         'Emily',     'Hall',       'IS',            'Manager of IT Operations', 'ACTIVE'),
('usr-017', 'matthew.allen',      'matthew.allen@hpsj.example.com',      'Matthew',   'Allen',      'IS',            'Manager of Application Development', 'ACTIVE'),
('usr-018', 'rachel.young',       'rachel.young@hpsj.example.com',       'Rachel',    'Young',      'IS',            'Manager of Information Security', 'ACTIVE'),
('usr-019', 'brandon.king',       'brandon.king@hpsj.example.com',       'Brandon',   'King',       'Configuration', 'Configuration Analyst Senior', 'ACTIVE'),
('usr-020', 'stephanie.wright',   'stephanie.wright@hpsj.example.com',   'Stephanie', 'Wright',     'Configuration', 'Configuration Analyst Intermediate', 'ACTIVE'),
('usr-021', 'andrew.lopez',       'andrew.lopez@hpsj.example.com',       'Andrew',    'Lopez',      'Configuration', 'Supervisor of Enterprise Configuration', 'ACTIVE'),
('usr-022', 'nicole.hill',        'nicole.hill@hpsj.example.com',        'Nicole',    'Hill',       'IS',            'Application Developer Senior', 'ACTIVE'),
('usr-023', 'ryan.scott',         'ryan.scott@hpsj.example.com',         'Ryan',      'Scott',      'IS',            'Application Developer Specialist', 'ACTIVE'),
-- Claims Reviewer (31)
('usr-024', 'carmen.reyes',       'carmen.reyes@hpsj.example.com',       'Carmen',    'Reyes',      'Claims',        'Claims Processor', 'ACTIVE'),
('usr-025', 'luis.hernandez',     'luis.hernandez@hpsj.example.com',     'Luis',      'Hernandez',  'Claims',        'Claims Processor', 'ACTIVE'),
('usr-026', 'diana.torres',       'diana.torres@hpsj.example.com',       'Diana',     'Torres',     'Claims',        'Claims Processor', 'ACTIVE'),
('usr-027', 'jose.ramirez',       'jose.ramirez@hpsj.example.com',       'Jose',      'Ramirez',    'Claims',        'Claims Processor', 'ACTIVE'),
('usr-028', 'michelle.flores',    'michelle.flores@hpsj.example.com',    'Michelle',  'Flores',     'Claims',        'Claims Processor', 'ACTIVE'),
('usr-029', 'ricardo.morales',    'ricardo.morales@hpsj.example.com',    'Ricardo',   'Morales',    'Claims',        'Claims Processor', 'ACTIVE'),
('usr-030', 'ana.gutierrez',      'ana.gutierrez@hpsj.example.com',      'Ana',       'Gutierrez',  'Claims',        'Claims Processor', 'ACTIVE'),
('usr-031', 'jorge.diaz',         'jorge.diaz@hpsj.example.com',         'Jorge',     'Diaz',       'Claims',        'Claims Processor', 'ACTIVE'),
('usr-032', 'elena.castro',       'elena.castro@hpsj.example.com',       'Elena',     'Castro',     'Claims',        'Claims Processor', 'ACTIVE'),
('usr-033', 'carlos.ruiz',        'carlos.ruiz@hpsj.example.com',        'Carlos',    'Ruiz',       'Claims',        'Claims Processor', 'ACTIVE'),
('usr-034', 'rosa.mendez',        'rosa.mendez@hpsj.example.com',        'Rosa',      'Mendez',     'Claims',        'Analyst Claims Data', 'ACTIVE'),
('usr-035', 'fernando.ortiz',     'fernando.ortiz@hpsj.example.com',     'Fernando',  'Ortiz',      'Claims',        'Analyst Claims Data Senior', 'ACTIVE'),
('usr-036', 'isabela.vargas',     'isabela.vargas@hpsj.example.com',     'Isabela',   'Vargas',     'Claims',        'Analyst Claims Lead', 'ACTIVE'),
('usr-037', 'marcos.silva',       'marcos.silva@hpsj.example.com',       'Marcos',    'Silva',      'Claims',        'Analyst Claims Data', 'ACTIVE'),
('usr-038', 'laura.romero',       'laura.romero@hpsj.example.com',       'Laura',     'Romero',     'Claims',        'Claims Quality Assurance Analyst', 'ACTIVE'),
('usr-039', 'pedro.jimenez',      'pedro.jimenez@hpsj.example.com',      'Pedro',     'Jimenez',    'Claims',        'Claims Quality Assurance Analyst', 'ACTIVE'),
('usr-040', 'sofia.navarro',      'sofia.navarro@hpsj.example.com',      'Sofia',     'Navarro',    'Claims',        'Claims Recovery Analyst', 'ACTIVE'),
('usr-041', 'gabriel.delgado',    'gabriel.delgado@hpsj.example.com',    'Gabriel',   'Delgado',    'Claims',        'Claims Recovery Analyst', 'ACTIVE'),
('usr-042', 'valentina.cruz',     'valentina.cruz@hpsj.example.com',     'Valentina', 'Cruz',       'Claims',        'Claims Refunds Specialist', 'ACTIVE'),
('usr-043', 'diego.ramos',        'diego.ramos@hpsj.example.com',        'Diego',     'Ramos',      'Claims',        'Claims Refunds Specialist', 'ACTIVE'),
('usr-044', 'andrea.medina',      'andrea.medina@hpsj.example.com',      'Andrea',    'Medina',     'Claims',        'Claims Adjustment Specialist', 'ACTIVE'),
('usr-045', 'miguel.aguilar',     'miguel.aguilar@hpsj.example.com',     'Miguel',    'Aguilar',    'Claims',        'Claims Adjustment Specialist', 'ACTIVE'),
('usr-046', 'adriana.pena',       'adriana.pena@hpsj.example.com',       'Adriana',   'Pena',       'Claims',        'Data Entry Clerk Claims', 'ACTIVE'),
('usr-047', 'oscar.herrera',      'oscar.herrera@hpsj.example.com',      'Oscar',     'Herrera',    'Claims',        'Data Entry Clerk Claims', 'ACTIVE'),
('usr-048', 'mariana.sandoval',   'mariana.sandoval@hpsj.example.com',   'Mariana',   'Sandoval',   'Claims',        'Supervisor Claims Processing', 'ACTIVE'),
('usr-049', 'rafael.guerrero',    'rafael.guerrero@hpsj.example.com',    'Rafael',    'Guerrero',   'Claims',        'Supervisor Claims Quality', 'ACTIVE'),
('usr-050', 'teresa.fuentes',     'teresa.fuentes@hpsj.example.com',     'Teresa',    'Fuentes',    'Claims',        'Claims Dispute Specialist', 'ACTIVE'),
('usr-051', 'alejandro.rios',     'alejandro.rios@hpsj.example.com',     'Alejandro', 'Rios',       'Claims',        'Claims Dispute Specialist', 'ACTIVE'),
('usr-052', 'lucia.soto',         'lucia.soto@hpsj.example.com',         'Lucia',     'Soto',       'Claims',        'Claims Processor', 'ACTIVE'),
('usr-053', 'pablo.vega',         'pablo.vega@hpsj.example.com',         'Pablo',     'Vega',       'Claims',        'Claims Processor', 'ACTIVE'),
('usr-054', 'natalia.campos',     'natalia.campos@hpsj.example.com',     'Natalia',   'Campos',     'Claims',        'Claims Processor', 'ACTIVE'),
-- System View Only (23)
('usr-055', 'karen.mitchell',     'karen.mitchell@hpsj.example.com',     'Karen',     'Mitchell',   'Service Delivery', 'Director of Service Delivery', 'ACTIVE'),
('usr-056', 'brian.campbell',     'brian.campbell@hpsj.example.com',      'Brian',     'Campbell',   'Service Delivery', 'Service Delivery Manager', 'ACTIVE'),
('usr-057', 'lisa.parker',        'lisa.parker@hpsj.example.com',        'Lisa',      'Parker',     'Service Delivery', 'Director Enterprise System Data Integrity', 'ACTIVE'),
('usr-058', 'jason.evans',        'jason.evans@hpsj.example.com',        'Jason',     'Evans',      'Service Delivery', 'Enterprise System Data Integrity Analyst Senior', 'ACTIVE'),
('usr-059', 'angela.edwards',     'angela.edwards@hpsj.example.com',     'Angela',    'Edwards',    'Service Delivery', 'Enterprise System Data Integrity Analyst Associate', 'ACTIVE'),
('usr-060', 'eric.collins',       'eric.collins@hpsj.example.com',       'Eric',      'Collins',    'Service Delivery', 'Enterprise System Data Integrity Auditor', 'ACTIVE'),
('usr-061', 'heather.stewart',    'heather.stewart@hpsj.example.com',    'Heather',   'Stewart',    'Service Delivery', 'Enterprise System Data Integrity Coordinator', 'ACTIVE'),
('usr-062', 'timothy.sanchez',    'timothy.sanchez@hpsj.example.com',    'Timothy',   'Sanchez',    'Service Delivery', 'Claims Configuration Program Manager', 'ACTIVE'),
('usr-063', 'cynthia.morris',     'cynthia.morris@hpsj.example.com',     'Cynthia',   'Morris',     'Service Delivery', 'Process Improvement Analyst', 'ACTIVE'),
('usr-064', 'gregory.rogers',     'gregory.rogers@hpsj.example.com',     'Gregory',   'Rogers',     'Service Delivery', 'Project Manager', 'ACTIVE'),
('usr-065', 'rebecca.reed',       'rebecca.reed@hpsj.example.com',       'Rebecca',   'Reed',       'Pharmacy',         'Manager Clinical Pharmacy', 'ACTIVE'),
('usr-066', 'mark.cook',          'mark.cook@hpsj.example.com',          'Mark',      'Cook',       'CMME',             'Member Benefits Administration Analyst', 'ACTIVE'),
('usr-067', 'kathleen.morgan',    'kathleen.morgan@hpsj.example.com',    'Kathleen',  'Morgan',     'CMME',             'Manager Benefit Administration', 'ACTIVE'),
('usr-068', 'steven.bell',        'steven.bell@hpsj.example.com',        'Steven',    'Bell',       'IS',               'End User Support Analyst', 'ACTIVE'),
('usr-069', 'laura.murphy',       'laura.murphy@hpsj.example.com',       'Laura',     'Murphy',     'IS',               'End User Support Engineer', 'ACTIVE'),
('usr-070', 'donald.bailey',      'donald.bailey@hpsj.example.com',      'Donald',    'Bailey',     'IS',               'Supervisor Customer Success', 'ACTIVE'),
('usr-071', 'sandra.rivera',      'sandra.rivera@hpsj.example.com',      'Sandra',    'Rivera',     'IS',               'Technical Writer', 'ACTIVE'),
('usr-072', 'george.cox',         'george.cox@hpsj.example.com',         'George',    'Cox',        'IS',               'Business Systems Analyst Intermediate', 'ACTIVE'),
('usr-073', 'deborah.howard',     'deborah.howard@hpsj.example.com',     'Deborah',   'Howard',     'IS',               'Corporate Data Analyst Intermediate', 'ACTIVE'),
('usr-074', 'kenneth.ward',       'kenneth.ward@hpsj.example.com',       'Kenneth',   'Ward',       'IS',               'Business Intelligence Analyst Intermediate', 'ACTIVE'),
('usr-075', 'sharon.torres',      'sharon.torres@hpsj.example.com',      'Sharon',    'Torres',     'IS',               'Data Warehouse Analyst Intermediate', 'ACTIVE'),
('usr-076', 'paul.peterson',      'paul.peterson@hpsj.example.com',      'Paul',      'Peterson',   'IS',               'Application Support Engineer Intermediate', 'ACTIVE'),
('usr-077', 'betty.gray',         'betty.gray@hpsj.example.com',         'Betty',     'Gray',       'IS',               'Service Integration Engineer', 'ACTIVE');

-- ==============================================================================
-- USER-ENTITLEMENT ASSIGNMENTS — based on RBAC matrix access_group
-- ==============================================================================

-- Enterprise Admins (usr-001 through usr-008)
INSERT INTO user_entitlements (user_id, entitlement_id, granted_by) VALUES
('usr-001', 'ces-enterprise-admin', 'system'),
('usr-002', 'ces-enterprise-admin', 'system'),
('usr-003', 'ces-enterprise-admin', 'system'),
('usr-004', 'ces-enterprise-admin', 'system'),
('usr-005', 'ces-enterprise-admin', 'system'),
('usr-006', 'ces-enterprise-admin', 'system'),
('usr-007', 'ces-enterprise-admin', 'system'),
('usr-008', 'ces-enterprise-admin', 'system');

-- CES Administrators (usr-009 through usr-023)
INSERT INTO user_entitlements (user_id, entitlement_id, granted_by) VALUES
('usr-009', 'ces-administrator', 'system'),
('usr-010', 'ces-administrator', 'system'),
('usr-011', 'ces-administrator', 'system'),
('usr-012', 'ces-administrator', 'system'),
('usr-013', 'ces-administrator', 'system'),
('usr-014', 'ces-administrator', 'system'),
('usr-015', 'ces-administrator', 'system'),
('usr-016', 'ces-administrator', 'system'),
('usr-017', 'ces-administrator', 'system'),
('usr-018', 'ces-administrator', 'system'),
('usr-019', 'ces-administrator', 'system'),
('usr-020', 'ces-administrator', 'system'),
('usr-021', 'ces-administrator', 'system'),
('usr-022', 'ces-administrator', 'system'),
('usr-023', 'ces-administrator', 'system');

-- Claims Reviewers (usr-024 through usr-054)
INSERT INTO user_entitlements (user_id, entitlement_id, granted_by) VALUES
('usr-024', 'ces-claims-reviewer', 'system'),
('usr-025', 'ces-claims-reviewer', 'system'),
('usr-026', 'ces-claims-reviewer', 'system'),
('usr-027', 'ces-claims-reviewer', 'system'),
('usr-028', 'ces-claims-reviewer', 'system'),
('usr-029', 'ces-claims-reviewer', 'system'),
('usr-030', 'ces-claims-reviewer', 'system'),
('usr-031', 'ces-claims-reviewer', 'system'),
('usr-032', 'ces-claims-reviewer', 'system'),
('usr-033', 'ces-claims-reviewer', 'system'),
('usr-034', 'ces-claims-reviewer', 'system'),
('usr-035', 'ces-claims-reviewer', 'system'),
('usr-036', 'ces-claims-reviewer', 'system'),
('usr-037', 'ces-claims-reviewer', 'system'),
('usr-038', 'ces-claims-reviewer', 'system'),
('usr-039', 'ces-claims-reviewer', 'system'),
('usr-040', 'ces-claims-reviewer', 'system'),
('usr-041', 'ces-claims-reviewer', 'system'),
('usr-042', 'ces-claims-reviewer', 'system'),
('usr-043', 'ces-claims-reviewer', 'system'),
('usr-044', 'ces-claims-reviewer', 'system'),
('usr-045', 'ces-claims-reviewer', 'system'),
('usr-046', 'ces-claims-reviewer', 'system'),
('usr-047', 'ces-claims-reviewer', 'system'),
('usr-048', 'ces-claims-reviewer', 'system'),
('usr-049', 'ces-claims-reviewer', 'system'),
('usr-050', 'ces-claims-reviewer', 'system'),
('usr-051', 'ces-claims-reviewer', 'system'),
('usr-052', 'ces-claims-reviewer', 'system'),
('usr-053', 'ces-claims-reviewer', 'system'),
('usr-054', 'ces-claims-reviewer', 'system');

-- System View Only (usr-055 through usr-077)
INSERT INTO user_entitlements (user_id, entitlement_id, granted_by) VALUES
('usr-055', 'ces-system-view-only', 'system'),
('usr-056', 'ces-system-view-only', 'system'),
('usr-057', 'ces-system-view-only', 'system'),
('usr-058', 'ces-system-view-only', 'system'),
('usr-059', 'ces-system-view-only', 'system'),
('usr-060', 'ces-system-view-only', 'system'),
('usr-061', 'ces-system-view-only', 'system'),
('usr-062', 'ces-system-view-only', 'system'),
('usr-063', 'ces-system-view-only', 'system'),
('usr-064', 'ces-system-view-only', 'system'),
('usr-065', 'ces-system-view-only', 'system'),
('usr-066', 'ces-system-view-only', 'system'),
('usr-067', 'ces-system-view-only', 'system'),
('usr-068', 'ces-system-view-only', 'system'),
('usr-069', 'ces-system-view-only', 'system'),
('usr-070', 'ces-system-view-only', 'system'),
('usr-071', 'ces-system-view-only', 'system'),
('usr-072', 'ces-system-view-only', 'system'),
('usr-073', 'ces-system-view-only', 'system'),
('usr-074', 'ces-system-view-only', 'system'),
('usr-075', 'ces-system-view-only', 'system'),
('usr-076', 'ces-system-view-only', 'system'),
('usr-077', 'ces-system-view-only', 'system');

-- ==============================================================================
-- USER-GROUP ASSIGNMENTS — department groups
-- ==============================================================================

INSERT INTO user_groups (user_id, group_id) VALUES
-- Claims department
('usr-001', 'grp-dept-claims'), ('usr-002', 'grp-dept-claims'), ('usr-008', 'grp-dept-claims'),
('usr-024', 'grp-dept-claims'), ('usr-025', 'grp-dept-claims'), ('usr-026', 'grp-dept-claims'),
('usr-027', 'grp-dept-claims'), ('usr-028', 'grp-dept-claims'), ('usr-029', 'grp-dept-claims'),
('usr-030', 'grp-dept-claims'), ('usr-031', 'grp-dept-claims'), ('usr-032', 'grp-dept-claims'),
('usr-033', 'grp-dept-claims'), ('usr-034', 'grp-dept-claims'), ('usr-035', 'grp-dept-claims'),
('usr-036', 'grp-dept-claims'), ('usr-037', 'grp-dept-claims'), ('usr-038', 'grp-dept-claims'),
('usr-039', 'grp-dept-claims'), ('usr-040', 'grp-dept-claims'), ('usr-041', 'grp-dept-claims'),
('usr-042', 'grp-dept-claims'), ('usr-043', 'grp-dept-claims'), ('usr-044', 'grp-dept-claims'),
('usr-045', 'grp-dept-claims'), ('usr-046', 'grp-dept-claims'), ('usr-047', 'grp-dept-claims'),
('usr-048', 'grp-dept-claims'), ('usr-049', 'grp-dept-claims'), ('usr-050', 'grp-dept-claims'),
('usr-051', 'grp-dept-claims'), ('usr-052', 'grp-dept-claims'), ('usr-053', 'grp-dept-claims'),
('usr-054', 'grp-dept-claims'),
-- Configuration department
('usr-003', 'grp-dept-configuration'), ('usr-004', 'grp-dept-configuration'),
('usr-019', 'grp-dept-configuration'), ('usr-020', 'grp-dept-configuration'),
('usr-021', 'grp-dept-configuration'),
-- IS department
('usr-005', 'grp-dept-is'), ('usr-006', 'grp-dept-is'), ('usr-007', 'grp-dept-is'),
('usr-009', 'grp-dept-is'), ('usr-010', 'grp-dept-is'), ('usr-011', 'grp-dept-is'),
('usr-012', 'grp-dept-is'), ('usr-013', 'grp-dept-is'), ('usr-014', 'grp-dept-is'),
('usr-015', 'grp-dept-is'), ('usr-016', 'grp-dept-is'), ('usr-017', 'grp-dept-is'),
('usr-018', 'grp-dept-is'), ('usr-022', 'grp-dept-is'), ('usr-023', 'grp-dept-is'),
('usr-068', 'grp-dept-is'), ('usr-069', 'grp-dept-is'), ('usr-070', 'grp-dept-is'),
('usr-071', 'grp-dept-is'), ('usr-072', 'grp-dept-is'), ('usr-073', 'grp-dept-is'),
('usr-074', 'grp-dept-is'), ('usr-075', 'grp-dept-is'), ('usr-076', 'grp-dept-is'),
('usr-077', 'grp-dept-is'),
-- Service Delivery
('usr-055', 'grp-dept-service-delivery'), ('usr-056', 'grp-dept-service-delivery'),
('usr-057', 'grp-dept-service-delivery'), ('usr-058', 'grp-dept-service-delivery'),
('usr-059', 'grp-dept-service-delivery'), ('usr-060', 'grp-dept-service-delivery'),
('usr-061', 'grp-dept-service-delivery'), ('usr-062', 'grp-dept-service-delivery'),
('usr-063', 'grp-dept-service-delivery'), ('usr-064', 'grp-dept-service-delivery'),
-- Pharmacy
('usr-065', 'grp-dept-pharmacy'),
-- CMME
('usr-066', 'grp-dept-cmme'), ('usr-067', 'grp-dept-cmme');

-- ==============================================================================
-- CES access group memberships
-- ==============================================================================

INSERT INTO user_groups (user_id, group_id) VALUES
-- Enterprise Admin group
('usr-001', 'grp-ces-enterprise-admin'), ('usr-002', 'grp-ces-enterprise-admin'),
('usr-003', 'grp-ces-enterprise-admin'), ('usr-004', 'grp-ces-enterprise-admin'),
('usr-005', 'grp-ces-enterprise-admin'), ('usr-006', 'grp-ces-enterprise-admin'),
('usr-007', 'grp-ces-enterprise-admin'), ('usr-008', 'grp-ces-enterprise-admin'),
-- Administrator group
('usr-009', 'grp-ces-administrator'), ('usr-010', 'grp-ces-administrator'),
('usr-011', 'grp-ces-administrator'), ('usr-012', 'grp-ces-administrator'),
('usr-013', 'grp-ces-administrator'), ('usr-014', 'grp-ces-administrator'),
('usr-015', 'grp-ces-administrator'), ('usr-016', 'grp-ces-administrator'),
('usr-017', 'grp-ces-administrator'), ('usr-018', 'grp-ces-administrator'),
('usr-019', 'grp-ces-administrator'), ('usr-020', 'grp-ces-administrator'),
('usr-021', 'grp-ces-administrator'), ('usr-022', 'grp-ces-administrator'),
('usr-023', 'grp-ces-administrator'),
-- Claims Reviewer group
('usr-024', 'grp-ces-claims-reviewer'), ('usr-025', 'grp-ces-claims-reviewer'),
('usr-026', 'grp-ces-claims-reviewer'), ('usr-027', 'grp-ces-claims-reviewer'),
('usr-028', 'grp-ces-claims-reviewer'), ('usr-029', 'grp-ces-claims-reviewer'),
('usr-030', 'grp-ces-claims-reviewer'), ('usr-031', 'grp-ces-claims-reviewer'),
('usr-032', 'grp-ces-claims-reviewer'), ('usr-033', 'grp-ces-claims-reviewer'),
('usr-034', 'grp-ces-claims-reviewer'), ('usr-035', 'grp-ces-claims-reviewer'),
('usr-036', 'grp-ces-claims-reviewer'), ('usr-037', 'grp-ces-claims-reviewer'),
('usr-038', 'grp-ces-claims-reviewer'), ('usr-039', 'grp-ces-claims-reviewer'),
('usr-040', 'grp-ces-claims-reviewer'), ('usr-041', 'grp-ces-claims-reviewer'),
('usr-042', 'grp-ces-claims-reviewer'), ('usr-043', 'grp-ces-claims-reviewer'),
('usr-044', 'grp-ces-claims-reviewer'), ('usr-045', 'grp-ces-claims-reviewer'),
('usr-046', 'grp-ces-claims-reviewer'), ('usr-047', 'grp-ces-claims-reviewer'),
('usr-048', 'grp-ces-claims-reviewer'), ('usr-049', 'grp-ces-claims-reviewer'),
('usr-050', 'grp-ces-claims-reviewer'), ('usr-051', 'grp-ces-claims-reviewer'),
('usr-052', 'grp-ces-claims-reviewer'), ('usr-053', 'grp-ces-claims-reviewer'),
('usr-054', 'grp-ces-claims-reviewer'),
-- System View Only group
('usr-055', 'grp-ces-system-view-only'), ('usr-056', 'grp-ces-system-view-only'),
('usr-057', 'grp-ces-system-view-only'), ('usr-058', 'grp-ces-system-view-only'),
('usr-059', 'grp-ces-system-view-only'), ('usr-060', 'grp-ces-system-view-only'),
('usr-061', 'grp-ces-system-view-only'), ('usr-062', 'grp-ces-system-view-only'),
('usr-063', 'grp-ces-system-view-only'), ('usr-064', 'grp-ces-system-view-only'),
('usr-065', 'grp-ces-system-view-only'), ('usr-066', 'grp-ces-system-view-only'),
('usr-067', 'grp-ces-system-view-only'), ('usr-068', 'grp-ces-system-view-only'),
('usr-069', 'grp-ces-system-view-only'), ('usr-070', 'grp-ces-system-view-only'),
('usr-071', 'grp-ces-system-view-only'), ('usr-072', 'grp-ces-system-view-only'),
('usr-073', 'grp-ces-system-view-only'), ('usr-074', 'grp-ces-system-view-only'),
('usr-075', 'grp-ces-system-view-only'), ('usr-076', 'grp-ces-system-view-only'),
('usr-077', 'grp-ces-system-view-only');

COMMIT;

-- ==============================================================================
-- VERIFICATION
-- ==============================================================================

SELECT 'Users' AS entity, COUNT(*) AS total FROM users
UNION ALL
SELECT 'Entitlements', COUNT(*) FROM entitlements
UNION ALL
SELECT 'User-Entitlement Assignments', COUNT(*) FROM user_entitlements
UNION ALL
SELECT 'Groups', COUNT(*) FROM groups
UNION ALL
SELECT 'User-Group Memberships', COUNT(*) FROM user_groups;

SELECT e.name AS role, COUNT(ue.id) AS assigned_users
FROM entitlements e
LEFT JOIN user_entitlements ue ON e.entitlement_id = ue.entitlement_id
GROUP BY e.name
ORDER BY assigned_users DESC;
