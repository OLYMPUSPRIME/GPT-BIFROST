# Hardcoded Values Audit

**Branch:** `feature/PIM_RBAC` · **Repository:** [GPT-BIFROST](https://github.com/OLYMPUSPRIME/GPT-BIFROST/tree/feature/PIM_RBAC)

This is a quick source review of hardcoded literals, environment assumptions, and module defaults. Line anchors may shift after edits. Some values are defaults or commented examples, not active deployment inputs. Not every literal is a defect: Azure API versions, required constants, deterministic names, and security baselines can be intentional.

## 1. Workflow and subscription configuration

| Location | Finding | Recommendation |
|---|---|---|
| [deploy.yml:31](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/.github/workflows/deploy.yml#L31) | Filters configuration to `environment == "dev"` | Resolve the environment from the validated Jira request. |
| [deploy.yml:72](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/.github/workflows/deploy.yml#L72) and [line 83](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/.github/workflows/deploy.yml#L83) | Fixed deployment location `eastus` | Use approved configuration and ensure what-if/create use the same location. |
| [subscriptions.json:4](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/config/subscriptions.json#L4) | Dev environment entry and configured subscription IDs | Obtain the requested Subscription ID from the approved Jira payload, then validate it against an approved-subscription allowlist. |
| [deploy.yml](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/.github/workflows/deploy.yml) | VM password handling was found to generate separate values for what-if and create | Generate once per run, reuse securely, mask it, and never log or commit it. Recheck current code before editing. |

## 2. Environment parameter files

### Development — [dev.bicepparam](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam)
- [Line 2](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam#L2): `environment = 'dev'` — expected for development.
- [Line 4](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam#L4): `location = 'eastus'` — confirm approved region.
- [Lines 30–61](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam#L30): commented examples include resource groups, CIDRs and tags such as `CC1001`, `LandingZone`, and `CloudOps`.
- [Lines 84–95](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam#L84): commented VM examples include `azureuser`, a Key Vault name, `Standard_D2s_v3`, ASG and tags.
- [Lines 190–253](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/dev.bicepparam#L190): commented peering names, location, vault SKU and gateway SKU; validate before enabling.

### Test — [test.bicepparam](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam)
- [Line 2](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam#L2): `environment = 'dev'` — likely mismatch; use `test` if this file represents test.
- [Line 4](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam#L4): `location = 'eastus'` — confirm test region.
- [Lines 13–19](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam#L13): `rg-dev-n` and dev-style tags — align to test naming.
- [Lines 27–39](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam#L27): CIDRs `10.0.0.0/16` and `10.0.1.0/24` — validate against the approved IP plan and check for overlap.
- [Lines 52–63](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/test.bicepparam#L52): `azureuser`, dev-style Key Vault/name/tags, and `Standard_D2s_v3` — verify for test.

### UAT and production
- [uat.bicepparam](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/uat.bicepparam): fetched content had no searchable non-empty lines; confirm whether it is empty or incomplete.
- [prod.bicepparam:2](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/prod.bicepparam#L2): `environment = 'dev'` — high-priority mismatch if intended for production.
- [prod.bicepparam:4](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/prod.bicepparam#L4): `location = 'eastus'` — confirm approved production region.
- [prod.bicepparam:13](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/environments/prod.bicepparam#L13): `rg-infra` — verify production naming and file completeness.

## 3. Bicep module findings

| Location | Value / behavior | Recommendation |
|---|---|---|
| [vm.bicep:66–69](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/compute/vm.bicep#L66) | Windows Server image publisher/offer and SKU `2019-Datacenter`, version `latest` | Parameterize or resolve from an approved image catalogue; validate allowed images. |
| [vnetgateway.bicep:9](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/networking/vnetgateway.bicep#L9) | Default SKU `VpnGw1AZ` | Validate against approved design and regional support. |
| [vnetgateway.bicep:28–30](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/networking/vnetgateway.bicep#L28) | Fixed availability zone value | Confirm SKU/region support. |
| [vnetPeering.bicep:26–29](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/networking/vnetPeering.bicep#L26) | Fixed forwarded-traffic/gateway-transit flags | Align with approved network design. |
| [backupPolicy.bicep:26](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/backup/backupPolicy.bicep#L26) | Daily backup frequency | Match approved backup policy. |
| [backupPolicy.bicep:42](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/backup/backupPolicy.bicep#L42) | Retention count `30` days | Use approved retention policy. |
| [recoveryVault.bicep:3](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/backup/recoveryVault.bicep#L3) | Default SKU `Standard` | Keep if policy-approved. |
| [recoveryVault.bicep:15](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/backup/recoveryVault.bicep#L15) | Public network access enabled | Review against vault network security requirements. |
| [metricAlert.bicep:23](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/monitoring/metricAlert.bicep#L23) | Default severity `2` | Use approved monitoring standard. |
| [metricAlert.bicep:29](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/monitoring/metricAlert.bicep#L29) and [line 32](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/monitoring/metricAlert.bicep#L32) | `PT5M` evaluation/window defaults | Match monitoring policy. |
| [keyvault.bicep:25–26](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/security/keyvault.bicep#L25) | SKU `standard`, family `A` | Keep if approved standard. |
| [keyvault.bicep:23](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/security/keyvault.bicep#L23) | RBAC authorization enabled | Recommended security baseline; keep enforced. |
| [keyvault.bicep:43](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/security/keyvault.bicep#L43) | `enableSoftDelete: false` | High-priority security/schema review; do not disable recovery protection without approval. |
| [keyvault.bicep:44](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/security/keyvault.bicep#L44) | Purge protection appears not enabled in shown configuration | Review policy and enable if required. |
| [storageAccount.bicep:6](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/storage/storageAccount.bicep#L6) | Container default `mycontainer` | Set workload-specific name if required. |
| [storageAccount.bicep:23](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/storage/storageAccount.bicep#L23) | SKU `Standard_LRS` | Match resilience/performance requirements. |
| [storageAccount.bicep:27](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/storage/storageAccount.bicep#L27) | Access tier `Hot` | Match access pattern and cost policy. |
| [storageAccount.bicep:30–32](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/storage/storageAccount.bicep#L30) | TLS 1.2, HTTPS-only, public blob access disabled | Security controls; generally keep enforced. |
| [storageAccount.bicep:82](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/storage/storageAccount.bicep#L82) | Commented CLI example contains a concrete subscription GUID | Remove or replace with `<subscription-id>`. |
| [pim.bicep:26](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/pim/pim.bicep#L26) | Default duration `P90D` | Use approved request/policy and validate allowed durations. |
| [pim.bicep:49](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/pim/pim.bicep#L49) | Principal type defaults to `User` | Derive from validated ticket where multiple types are allowed. |
| [pim.bicep:38](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/pim/pim.bicep#L38) | Deterministic suffix `pim-eligibility` | Intentional naming input; generally safe. |
| [rbac.bicep:21](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/rbac/rbac.bicep#L21) | Principal type defaults to `User` | Derive from validated ticket where appropriate. |
| [rbac.bicep:26](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/rbac/rbac.bicep#L26) | Deterministic role assignment GUID | Intentional idempotent naming; generally safe. |
| [rbac.bicep:1](https://github.com/OLYMPUSPRIME/GPT-BIFROST/blob/feature/PIM_RBAC/modules/rbac/rbac.bicep#L1) | Subscription-level scope | Design choice; support and validate other scopes if required. |

## Recommended priority

1. Correct environment labels in test/production and confirm UAT file content.
2. Replace dev-only workflow filtering with validated request-environment resolution.
3. Ensure what-if and create use the same subscription, location, parameters, and VM password.
4. Validate Jira inputs for subscription, region, module, SKU/image, networking, tags, and PIM/RBAC identity/role.
5. Parameterize workload-dependent values only where approved policy allows variation.
6. Keep security baselines enforced and remove concrete subscription identifiers from comments.
7. Run Bicep build, parameter validation, policy checks, and reviewed Azure what-if.

**Scope:** Quick source review, not a formal security scan. Verify current line anchors before edits because line numbers can shift. No deployment code is changed by this audit.