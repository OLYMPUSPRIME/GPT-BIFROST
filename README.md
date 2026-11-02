# 🌌 BIFROST — Azure Environment Provisioning with Bicep

> **Purpose:** BIFROST is an Infrastructure as Code (IaC) repository for provisioning and managing Azure infrastructure with reusable Bicep modules and GitHub Actions.

This guide covers the repository, deployment flow, PIKE alignment, JSON-driven deployment design, PIM configuration, and security considerations.

## 📚 Contents

- [Overview](#-overview)
- [Architecture and workflow](#-architecture-and-workflow)
- [PIKE end-to-end process](#-pike-end-to-end-process)
- [New project vs existing environment](#-new-project-vs-existing-environment)
- [Repository structure](#-repository-structure)
- [Module catalogue](#-module-catalogue)
- [JSON-driven deployment](#-json-driven-deployment)
- [PIM configuration guide](#-pim-configuration-guide)
- [Prerequisites](#-prerequisites)
- [Deployment and validation](#-deployment-and-validation)
- [PIKE alignment and implementation gaps](#-pike-alignment-and-implementation-gaps)
- [Security guidance](#-security-guidance)

---

## 🎯 Overview

BIFROST contains reusable Azure Bicep modules and GitHub Actions workflows. The intended deployment path is:

1. A request is raised and approved through Jira / PIKE.
2. Request details are validated against approved standards.
3. The selected subscription, region, resources, and module inputs are resolved.
4. GitHub Actions validates and previews the deployment.
5. Azure Resource Manager deploys the Bicep templates.
6. Results are verified and reported to the request system.

> **Current-state note:** Jira intake, cost approval, approval gates, requester notifications, and external monitoring are not all implemented in the current GitHub Actions workflow. Diagrams in this README distinguish the target process from current behavior.

### 🧭 Current workflow (manual workflow dispatch)

```mermaid
flowchart TD
  subgraph GitHub["🟪 GitHub Actions"]
    A["Run workflow manually on feature/PIM_RBAC"] --> B["Validate root input.json"]
    B --> C["Build Bicep"]
    C --> D["Generate temporary .bicepparam"]
    D --> E["Azure login with OIDC"]
    E --> F["Subscription What-If"]
    F --> G{"deploy_resources = true?"}
    G -->|Yes| H["Deploy"]
    G -->|No| I["Preview only"]
  end
  subgraph Azure["🟦 Azure"]
    H --> J["ARM deploys main.bicep"]
    J --> K["Inspect result"]
  end
  classDef gh fill:#f3e8ff,stroke:#7e22ce,color:#581c87;
  classDef az fill:#dbeafe,stroke:#2563eb,color:#1e3a8a;
  class A,B,C,D,E,F,G,I gh;
  class H,J,K az;
```

The workflow is **manual-only** using `workflow_dispatch`; it does not deploy automatically on push. It checks out the selected branch, validates `input.json`, builds `modules/main.bicep`, generates a temporary parameter file, authenticates using OIDC, and runs What-If.

- `deploy_resources=false`: preview only (default).
- `deploy_resources=true`: deploys after the What-If job succeeds.
- `deploy_pim=true`: includes PIM eligibility in the deployment. This is separately opt-in and requires privileged authorization.

Configure GitHub repository variables `AZURE_CLIENT_ID` and `AZURE_TENANT_ID`. Configure the `bifrost-dev` GitHub environment with required reviewers if an approval gate is desired.

---

## 🔁 PIKE end-to-end process

```mermaid
flowchart TD
  subgraph Intake["🟨 1–4 · Request and assessment"]
    A["Requester: DEV / QA / UAT / PROD"] --> B["Jira request"]
    B --> C["Collect required parameters"]
    C --> D{"New project or existing?"}
  end
  subgraph Design["🟧 5–8 · Design and approval"]
    D -->|New| E["Plan subscription, RG, network, shared services"]
    D -->|Existing| F["Validate existing Azure foundation"]
    E --> G["Apply landing-zone standards"]
    F --> G
    G --> H["Cost analysis"]
    H --> I["Designated approval"]
    I --> J{"Ready for Deployment?"}
  end
  subgraph Delivery["🟪 9–13 · Automation and deployment"]
    J -->|Yes| K["Jira automation sends request"]
    K --> L["Select approved Bicep modules"]
    L --> M["GitHub Actions validation"]
    M --> N["Bicep What-If"]
    N --> O["Deploy to Azure"]
    O --> P["Apply / verify mandatory tags"]
  end
  subgraph Closure["🟩 14–16 · Results and communication"]
    P --> Q["Record deployment outcome"]
    Q --> R["Update Jira"]
    R --> S["Notify requester"]
  end
  J -->|No| T["Return for clarification / approval"]
  T --> B
  P -.-> U["Azure Monitor / Logic Monitor / integration"]
  classDef intake fill:#fef9c3,stroke:#ca8a04,color:#713f12;
  classDef design fill:#ffedd5,stroke:#ea580c,color:#7c2d12;
  classDef delivery fill:#f3e8ff,stroke:#9333ea,color:#581c87;
  classDef closure fill:#dcfce7,stroke:#16a34a,color:#14532d;
  class A,B,C,D intake;
  class E,F,G,H,I,J,T design;
  class K,L,M,N,O,P delivery;
  class Q,R,S,U closure;
```

This represents the **target PIKE process**, not a claim that every step is automated today.

## 🏗️ New project vs existing environment

```mermaid
flowchart TD
  A["Approved request"] --> B{"New project?"}
  subgraph Foundation["🆕 New-project foundation"]
    C["Create / confirm subscription"] --> D["Create resource group"]
    D --> E["Create VNet, subnets, network controls"]
    E --> F["Create required shared services"]
  end
  subgraph Existing["♻️ Existing-project validation"]
    G["Confirm approved subscription / RG"]
    G --> H["Validate network and shared services"]
  end
  B -->|Yes| C
  B -->|No| G
  F --> I["Apply environment standards"]
  H --> I
  I --> J["Cost estimate and approval"]
  J --> K["Build deployment request"]
  classDef foundation fill:#dbeafe,stroke:#2563eb,color:#1e3a8a;
  classDef existing fill:#f3e8ff,stroke:#9333ea,color:#581c87;
  classDef shared fill:#dcfce7,stroke:#16a34a,color:#14532d;
  class C,D,E,F foundation;
  class G,H existing;
  class I,J,K shared;
```

---

## 📂 Repository structure

```text
.
├── input.json                       # Root deployment input (target single source)
├── config/
│   └── subscriptions.json           # Subscription / environment allowlist-matrix
├── .github/
│   └── workflows/
│       └── deploy.yml               # GitHub Actions deployment workflow
├── environments/
│   └── dev.bicepparam               # Legacy/current environment parameter file
└── modules/
    ├── main.bicep                   # Subscription-scope orchestrator
    ├── resourcegroup.bicep
    ├── compute/
    ├── networking/
    ├── storage/
    ├── security/
    ├── backup/
    ├── monitoring/
    ├── pim/
    └── rbac/
```

📖 Module-specific guides are available in the module directories and `modules/README.md`.

## 🧰 Module catalogue

| Module area | Function | Main dependencies |
|---|---|---|
| Resource group | Create Azure RGs | Subscription, region |
| Compute / VM | VM and NIC | RG, VNet/subnet, optional ASG/Key Vault |
| Networking / VNet | VNet and subnets | RG, CIDR plan |
| Networking / NSG | Network security rules | RG, approved rules |
| ASG | Application Security Group | RG |
| Route table | User-defined routes | RG, route design |
| VNet peering | VNet peering | Both VNets, non-overlapping CIDRs |
| VPN gateway | Gateway and public IP | VNet, GatewaySubnet |
| Storage | Storage account / container | RG, unique account name |
| Key Vault | Vault | RG, access-control design |
| Backup | Recovery vault, policy, VM protection | VM, vault, policy |
| Monitoring | Action group and metric alert | Target resource and action group |
| PIM | Eligible Azure RBAC access | Principal Object ID, role ID, PIM authorization |
| RBAC | Direct role assignment | Principal Object ID, role ID, role-assignment authorization |

PIM eligibility is optionally orchestrated by `modules/main.bicep` when both `input.json` enables PIM and the workflow input `deploy_pim` is true. RBAC direct assignment remains a separate module.

---

## 🔄 JSON-driven deployment

Root `input.json` is the source of configuration for this workflow. GitHub Actions writes the JSON object into a temporary `.bicepparam` file and passes it to `modules/main.bicep` as the `config` object.

```mermaid
flowchart TD
  subgraph Config["📄 Configuration"]
    A["input.json"]
  end
  subgraph Workflow["⚙️ GitHub Actions"]
    B["Validate JSON and required fields"] --> C["Bicep build"]
    C --> D["Generate temporary .bicepparam"]
    D --> E["Azure OIDC login"]
    E --> F["What-If"]
    F --> G{"Deploy checkbox enabled?"}
    G -->|No| H["Preview only"]
    G -->|Yes| I["Deploy with same input"]
    I --> J["Cleanup generated parameter file"]
  end
  subgraph Azure["☁️ Azure"]
    E --> K["BIFROST-SC"]
    K --> F
    I --> L["Resource Group + VNet + NSG + Linux VM"]
    I -. optional .-> M["PIM eligibility request"]
  end
  A --> B
  classDef source fill:#fef9c3,stroke:#ca8a04,color:#713f12;
  classDef actions fill:#f3e8ff,stroke:#9333ea,color:#581c87;
  classDef azure fill:#dbeafe,stroke:#2563eb,color:#1e3a8a;
  class A source;
  class B,C,D,E,F,G,H,I,J actions;
  class K,L,M azure;
```

### Deployment behavior

1. Validate JSON syntax and ensure the request is marked approved.
2. Restrict the run to the BIFROST-SC subscription ID and the `dev` environment.
3. Require a valid SSH public key and a **single trusted SSH source IP** (`/32` IPv4 or `/128` IPv6).
4. Check that the VM and PIM scope Resource Group match the root Resource Group.
5. Generate the temporary parameter file on the runner.
6. Authenticate to Azure with OIDC and verify the logged-in subscription/tenant.
7. Run What-If.
8. Deploy only when the manual `deploy_resources` input is true.
9. Remove the generated parameter file.

The temporary parameter file is not committed. Do not put passwords, client secrets, or other secrets in `input.json`. The current Linux VM uses SSH key authentication, not password authentication.

## 🔐 PIM configuration guide

The root `input.json` PIM section needs:

- `pim.principal.principalId`: Entra ID Object ID of the user, group, or service principal receiving access.
- `pim.role.roleDefinitionId`: Azure RBAC Role Definition ID for the requested role.

### Step 1 — Sign in to Azure CLI

```bash
az login
```

If needed, select the target subscription:

```bash
az account set --subscription "<BIFROST-SC-SUBSCRIPTION-ID>"
```

### Step 2 — Get the PIM Principal ID

For the currently signed-in user:

```bash
az ad signed-in-user show --query id --output tsv
```

For a specific user:

```bash
az ad user show --id "user@company.com" --query id --output tsv
```

For a group:

```bash
az ad group show --group "<group-name-or-id>" --query id --output tsv
```

Replace the sample user UPN or group identifier with the intended recipient. Set `principalType` to `User` or `Group` accordingly.

### Step 3 — Get the Contributor Role Definition ID

The built-in Azure Contributor role GUID is:

```text
b24988ac-6180-42a0-ab88-20f7382dd24c
```

Retrieve the GUID using Azure CLI:

```bash
az role definition list --name "Contributor" --query "[0].name" --output tsv
```

Retrieve the full role definition resource ID:

```bash
az role definition list --name "Contributor" --query "[0].id" --output tsv
```

Use the GUID or full resource ID according to the parameter contract of your PIM Bicep module. Contributor grants broad resource management rights but does not generally grant permission to assign roles or create PIM eligibility assignments.

### 🧭 PIM ID discovery flow

```mermaid
flowchart TD
  subgraph Login["🔑 Authentication"]
    A["Open terminal / Azure CLI"] --> B["az login"]
    B --> C["Select BIFROST subscription"]
  end
  subgraph Principal["👤 Resolve principal"]
    C --> D{"Principal type?"}
    D -->|User| E["az ad user show / signed-in-user show"]
    D -->|Group| F["az ad group show"]
    E --> G["Copy Entra Object ID"]
    F --> G
  end
  subgraph Role["🛡️ Resolve role"]
    G --> H["Query Contributor role definition"]
    H --> I["Copy Role Definition GUID"]
  end
  subgraph Input["📝 Update configuration"]
    I --> J["Set principalId and roleDefinitionId in input.json"]
    J --> K["Review principal, role, scope, duration"]
  end
  classDef login fill:#dbeafe,stroke:#2563eb,color:#1e3a8a;
  classDef principal fill:#f3e8ff,stroke:#9333ea,color:#581c87;
  classDef role fill:#ffedd5,stroke:#ea580c,color:#7c2d12;
  classDef input fill:#dcfce7,stroke:#16a34a,color:#14532d;
  class A,B,C login;
  class D,E,F,G principal;
  class H,I role;
  class J,K input;
```

### Example PIM configuration

```json
"pim": {
  "enabled": true,
  "assignmentType": "Eligibility",
  "principal": {
    "principalId": "<ENTRA-USER-OBJECT-ID>",
    "principalType": "User"
  },
  "role": {
    "roleName": "Contributor",
    "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c"
  }
}
```

⚠️ **Important:** Principal ID is not an email/UPN, subscription ID, or tenant ID. It is the Entra Object ID of the recipient. Confirm principal, role, scope, duration, and approval before creating privileged access.

---

## ✅ Prerequisites

Before deployment, verify:

1. The Azure subscription exists and is the intended target.
2. An Entra application/service principal is configured for GitHub OIDC federation.
3. GitHub Actions variables `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` are configured.
4. The federated credential trusts the correct repository and branch/environment.
5. The deployment identity has required permissions. PIM eligibility and role assignment operations require specific authorization beyond ordinary Contributor.
6. Parameter files match the Bicep template parameters.
7. Resource provider registration, quotas, naming, regions, and tags are checked.

---

## 🚀 Deployment and validation

### Before running the workflow

- Replace `virtualMachine.sshPublicKey` with your **public** SSH key (never paste the private key).
- Replace `virtualMachine.network.sshAllowedSourceAddressPrefix` with your current public IP in host CIDR format, e.g. `203.0.113.10/32`. This example IP is documentation-only.
- Verify the subscription ID and tenant ID in `input.json`.
- Confirm the Azure app's federated credential trusts the repository and selected branch.
- Confirm the GitHub variables `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` are configured.
- Confirm the deployment identity has permissions to create the RG, VNet, NSG, public IP, NIC, and VM. PIM requires additional privileged authorization.

### Run from GitHub UI

1. Open **Actions → BIFROST | Input JSON Deployment**.
2. Choose the `feature/PIM_RBAC` branch.
3. Keep `deploy_resources` unchecked for What-If only.
4. Select **Run workflow** and review the What-If output.
5. If approved, run again with `deploy_resources` checked.
6. Select `deploy_pim` only when you intentionally want to create PIM eligibility and have the required permissions.
7. Review the GitHub `bifrost-dev` environment approval (if configured) and Azure deployment status.

The deployment region is taken from `input.json` (currently `centralindia`). This workflow is currently restricted to BIFROST-SC and `dev`; it does not use the old subscription matrix or `environments/dev.bicepparam`.

## 📊 PIKE alignment and implementation gaps

**Current status: partially aligned.**

| PIKE step | Status | Current note |
|---|---|---|
| Requester / Jira | ⏳ Not implemented | Jira intake is not wired into workflow |
| Request parameters | 🟢 Implemented for this workflow | Root JSON parsed and passed to Bicep |
| New vs existing project | ⏳ Not automated | Requires assessment flow |
| Standards / landing zone | 🟡 Partial | Reusable modules exist; enforcement incomplete |
| Cost analysis | ⏳ Not implemented | No cost gate |
| Approval / Ready status | 🟡 Partial | Manual workflow dispatch; request approval field is checked |
| Jira automation | ⏳ Not implemented | No ticket webhook/API intake |
| Bicep module selection | 🟡 Partial | Modules exist; dynamic mapping needs work |
| GitHub Actions / Azure deployment | 🟢 Implemented | OIDC, What-If, optional deploy, Linux SSH VM module |
| Mandatory tagging | 🟡 Partial | Some templates accept tags; universal enforcement not proven |
| Result reporting | 🟡 Partial | Azure/GitHub status available; no structured Jira result |
| Jira update / requester notification | ⏳ Not implemented | Integration pending |
| Monitoring integration | 🟡 Partial | Alert modules exist; external integration pending |

### 🔧 Recommended implementation order

1. Define a versioned Jira JSON request schema.
2. Add authenticated Jira event intake and Ready-for-Deployment validation.
3. Add new-project vs existing-environment assessment.
4. Enforce approved naming, SKU, OS, region, network, and security standards.
5. Add cost estimation and formal approval gates.
6. Extend JSON schema and module coverage for additional resource types.
7. Add lint, policy checks, and mandatory review/approval controls.
8. Add Azure Key Vault integration if future resources require secrets.
9. Enforce mandatory tags across supported resources.
10. Capture deployment status, resource IDs, and errors in structured outputs.
11. Update Jira and notify requester on completion.
12. Integrate monitoring, diagnostics, and external tooling.

---

## 🛡️ Security guidance

- Prefer GitHub OIDC/workload identity federation over long-lived client secrets.
- Separate test and production identities.
- Follow least privilege, especially for PIM/RBAC.
- Use approvals for production and privileged access.
- What-If is a preview, not an approval control.
- Use the same reviewed inputs for What-If and deployment.
- Never commit passwords, secrets, or generated credentials.
- Avoid printing sensitive data in workflow logs.
- Validate Bicep and parameters before deployment.
- Keep docs synchronized with actual workflows and modules.

---

## 🔗 Related documentation

- [Module documentation index](modules/README.md)
- [Main Bicep orchestration guide](modules/main.md)
- [PIM module guide](modules/pim/README.md)
- [RBAC module guide](modules/rbac/README.md)
- [GitHub Actions workflow](.github/workflows/deploy.yml)

> **Repository status:** BIFROST provides the core IaC foundation. Jira integration, project assessment, cost/approval gates, complete tag enforcement, structured request updates, notifications, and external monitoring integration remain future implementation work.
