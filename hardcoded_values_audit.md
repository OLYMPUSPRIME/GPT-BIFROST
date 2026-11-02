# 🔎 Hardcoded Values Audit — GPT-BIFROST

**Branch:** `feature/PIM_RBAC`  
**Audit date:** 2026-11-02  
**Scope:** `.github/workflows/deploy.yml`, root `input.json`, and Bicep modules currently orchestrated by the workflow.

> This audit distinguishes configuration values that should be parameterized from deliberate platform/API constants and security guardrails. Values in `input.json` are repository configuration, not runtime secrets.

## Summary
- Resource names, location, VM sizing, network CIDRs, SSH key, OS disk, tags, PIM target/role/duration are configured in root `input.json` or passed from it.
- The workflow contains intentional BIFROST-SC subscription and `dev` environment guardrails.
- Azure API versions, resource types, SSH port 22, Linux SSH behavior, and PIM request type are platform constants.
- GitHub variables `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` are external configuration.
- **Important:** What-If runs `modules/main.bicep`, but individual deploy jobs currently use Azure CLI for several resources. What-If is therefore not a preview of the exact CLI deployment steps.

## 1. Workflow hardcoded values

| Value | Location | Classification | Recommendation |
|---|---|---|---|
| BIFROST-SC subscription UUID `efa057fe-e3b8-462a-98ba-08e0024d2442` | Workflow validation | Intentional safety allowlist | Keep guardrail or move to protected GitHub variable. |
| `dev` environment | Workflow validation | Intentional guardrail | Keep until additional environments are supported. |
| GitHub environment `bifrost-dev` | Deploy jobs | Approval/environment selector | Configure required reviewers in GitHub. |
| `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` | GitHub vars | External configuration | Set in repo/environment variables; do not hardcode secrets. |
| Tag values `Project=BIFROST`, `Environment=Dev`, `DeploymentMethod=Bicep`, `ManagedBy=GitHubActions` | CLI resource commands | Repeated config | Pass complete tags from JSON to reduce duplication. |
| SSH port `22`, TCP, NSG priority `100` | NSG job | Security/platform constants | Keep standard SSH settings; document priority. |
| Public IP SKU `Standard`, allocation `Static` | Public IP job | Configuration duplication | Pass these from `input.json` in future; they currently exist in JSON too. |
| GitHub run number in Azure deployment names | Workflow | Operational uniqueness | Keep. |
| Action major versions (`actions/checkout@v4`, `azure/login@v2`, etc.) | Workflow | Dependency references | Consider pinning action commit SHAs for supply-chain hardening. |

## 2. Root input.json values

| Setting | JSON path | Notes |
|---|---|---|
| Ticket/request metadata | `request.*` | Requester, ticket, approval, environment |
| Subscription/tenant | `subscription.*` | BIFROST-SC target |
| Region | `deployment.location` | Current value: `centralindia` |
| RG name/location/tags | `resourceGroup.*` | Target scope |
| VM name, location, SKU, OS, username | `virtualMachine.*` | VM configuration |
| SSH public key | `virtualMachine.sshPublicKey` | Public key only; never commit private key |
| Image publisher/offer/SKU/version | `virtualMachine.image.*` | OS image reference |
| OS disk configuration | `virtualMachine.osDisk.*` | Disk name/size/type/cache |
| VNet/subnet/CIDRs | `virtualMachine.network.*` | Check ranges for overlap |
| NSG name/source CIDR | `virtualMachine.network.*` | Restrict source to host IP (/32 or /128) |
| Public IP settings | `virtualMachine.network.publicIp.*` | Some current CLI commands still use constants |
| Tags | `resourceGroup.tags`, `virtualMachine.tags` | CLI commands currently duplicate some tag values |
| PIM principal/role/scope/duration | `pim.*` | Verify principal Object ID and role definition ID |

## 3. Bicep constants

| Value | File | Classification | Recommendation |
|---|---|---|---|
| Azure resource API versions | Bicep resource declarations | Azure API version constants | Keep versioned; periodically review. |
| Linux authorized_keys path | `modules/compute/vm.bicep` | Linux convention | Keep derived from admin username. |
| `disablePasswordAuthentication: true` | VM module | Security default | Keep for SSH-only authentication. |
| SSH port and NSG rule fields | Main/NSG modules | Security behavior | Keep restricted to approved source IP. |
| PIM `requestType: AdminAssign` | PIM module | Azure PIM API operation | Confirm intended eligible assignment and permissions. |
| PIM duration default `P90D` | PIM module | Module default | Workflow should pass JSON duration explicitly. |
| Bicep module paths | `modules/main.bicep` | Repo layout | Keep relative paths. |

## 4. Placeholder values blocking deployment

- `virtualMachine.sshPublicKey`: replace `<SSH-PUBLIC-KEY>` with a real public key.
- `virtualMachine.network.sshAllowedSourceAddressPrefix`: replace `<YOUR-PUBLIC-IP>/32` with actual trusted IP host CIDR.

Workflow validation should fail while these placeholders remain.

## 5. Deployment/What-If consistency

The What-If job uses `modules/main.bicep`; resource-specific deploy jobs currently use Azure CLI for RG, NSG, VNet, Public IP, NIC, and VM.

Consequences:
- What-If does **not** preview the exact CLI operations that follow.
- Some tag and Public IP settings are duplicated in workflow code.
- Bicep build/lint does not validate CLI commands or the actual Azure resource operations.

**Recommended:** deploy each resource/job through its Bicep module using values derived from `input.json`, or run What-If and deployment through the same main Bicep template.

## 6. Secret handling
- Never store private SSH keys, passwords, or client secrets in `input.json`.
- Use OIDC with `azure/login`.
- Keep GitHub variables and environment protection settings scoped appropriately.
- SSH public keys are not secret, but should be reviewed as deployment configuration.

## 7. Audit status

| Category | Status |
|---|---|
| Resource configuration in JSON | 🟢 Centralized |
| Subscription allowlist | 🟡 Intentionally hardcoded |
| Tags and Public IP settings in CLI | 🟠 Duplication remains |
| API/platform constants | 🟢 Intentional |
| SSH key/source CIDR placeholders | 🔴 Must be replaced |
| What-If parity with deployment | 🟠 Needs alignment |
