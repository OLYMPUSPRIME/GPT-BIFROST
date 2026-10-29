# BIFROST — Azure Environment Provisioning with Bicep

> **Purpose:** BIFROST is an Infrastructure as Code (IaC) repository for provisioning and managing Azure environment resources using Bicep modules and GitHub Actions.

This README explains the repository structure, how a deployment currently runs, how that process relates to the PIKE end-to-end Azure Environment Provisioning workflow, and what remains to be implemented for full alignment.

## Table of contents

- [Overview](#overview)
- [Repository workflow today](#repository-workflow-today)
- [End-to-end PIKE workflow](#end-to-end-pike-workflow)
- [New project vs existing environment](#new-project-vs-existing-environment)
- [Repository structure](#repository-structure)
- [Current module catalogue](#current-module-catalogue)
- [Deployment flow](#deployment-flow)
- [Prerequisites and configuration](#prerequisites-and-configuration)
- [How to run a deployment](#how-to-run-a-deployment)
- [Comparison with the PIKE process diagram](#comparison-with-the-pike-process-diagram)
- [Gaps to close for full alignment](#gaps-to-close-for-full-alignment)
- [Security and operational guidance](#security-and-operational-guidance)

## Overview

BIFROST separates Azure resource definitions into reusable Bicep templates, uses `modules/main.bicep` to orchestrate supported infrastructure modules, stores environment inputs in `environments/*.bicepparam`, and uses GitHub Actions to authenticate to Azure and run a subscription deployment.

The intended operating model is:

1. A requester raises an approved request in Jira or the agreed intake system.
2. Request details are assessed and mapped to an approved environment standard.
3. The deployment payload selects the environment, subscription, resource group, region, and required resource modules.
4. GitHub Actions validates and previews the requested infrastructure.
5. Azure Resource Manager deploys the selected Bicep resources.
6. The resulting resource details and deployment status are verified and reported back to the request process.

**Important:** Steps involving Jira, project assessment, formal cost approval, designated approvers, requester notification, and external monitoring are part of the target PIKE workflow. They are not all automated by the current repository workflow yet.

## Repository workflow today

```mermaid
flowchart TD
    A[Commit or push to Dev branch] --> B[GitHub Actions workflow starts]
    B --> C[Validate config/subscriptions.json syntax]
    C --> D[Select configuration entries for dev]
    D --> E[Build deployment matrix]
    E --> F[Authenticate to Azure using OIDC]
    F --> G[Read environment .bicepparam file]
    G --> H[Run subscription deployment what-if]
    H --> I[Run subscription deployment create]
    I --> J[Azure Resource Manager deploys modules/main.bicep]
    J --> K[Inspect deployment result in Azure and GitHub Actions]
```

The current workflow is `.github/workflows/deploy.yml`. It triggers on pushes to the `Dev` branch, selects configuration entries whose environment is `dev`, authenticates using `azure/login@v2` and GitHub OIDC, runs `what-if`, then runs `az deployment sub create`.

> **Current behavior to be aware of:** the workflow generates the VM administrator password independently in the what-if step and the deployment step. The preview and actual deployment therefore do not use the same generated value. Also, the current workflow proceeds from what-if to deployment without a separate human approval gate. Treat this as a test workflow until approval, secret handling, and deployment controls are reviewed.

## End-to-end PIKE workflow

This is the intended business and technical process represented by the shared “Azure Environment Provisioning — End to End Flow (Updated)” diagram.

```mermaid
flowchart TD
    A[1. Requester: DEV / QA / UAT / PROD] --> B[2. Jira request entry]
    B --> C[3. Collect request parameters]
    C --> D[4. Project assessment: new or existing?]

    D -->|New project| E[Build foundation: subscription, RG, network, shared services]
    D -->|Existing project| F[Reuse approved subscription, RG, network and shared services]

    E --> G[5. Apply environment / landing-zone standards]
    F --> G
    G --> H[6. Cost analysis]
    H --> I[7. Designated approval]
    I --> J{8. Status is Ready for Deployment?}

    J -->|No| K[Return for clarification or approval]
    K --> B
    J -->|Yes| L[9. Jira automation sends event / payload]

    L --> M[10. Map request to approved Bicep modules]
    M --> N[11. GitHub Actions validates inputs and resolves configuration]
    N --> O[Select subscription, region, resource group and parameters]
    O --> P[Run Bicep validation and what-if]
    P --> Q{Deployment approved and preview accepted?}
    Q -->|No| K
    Q -->|Yes| R[12. Deploy to Azure target]
    R --> S[13. Apply and verify mandatory tags]
    S --> T[14. Record success / failure and resource details]
    T --> U[15. Update Jira ticket]
    U --> V[16. Notify requester]
    S -.-> W[Monitoring and integration]
    W -.-> X[Azure Monitor / Logic Monitor / external integration]
```

The Mermaid diagram is a representation of the target process, not a claim that every step is currently automated in this repository.

## New project vs existing environment

The project assessment step determines whether BIFROST should create foundational services or reuse existing approved infrastructure.

```mermaid
flowchart TD
    A[Approved request] --> B{New project?}
    B -->|Yes| C[Create / confirm subscription]
    C --> D[Create resource group]
    D --> E[Create VNet, subnets and required network controls]
    E --> F[Create required shared services]
    B -->|No| G[Validate existing subscription and resource group]
    G --> H[Validate existing VNet, subnet and shared services]
    F --> I[Apply environment standards]
    H --> I
    I --> J[Estimate cost and obtain approval]
    J --> K[Prepare deployment payload]
```

The current templates cover several foundation components, but subscription creation, request assessment, cost estimation, and approval are not implemented as a complete automated intake flow.

## Repository structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions subscription deployment
├── config/
│   └── subscriptions.json         # Environment / subscription deployment matrix
├── environments/
│   ├── dev.bicepparam             # Development input values
│   ├── test.bicepparam            # Test input values
│   ├── uat.bicepparam             # UAT input values
│   └── prod.bicepparam            # Production input values
├── modules/
│   ├── main.bicep                 # Subscription-scope orchestrator
│   ├── README.md                  # Module documentation index
│   ├── resourcegroup.bicep
│   ├── resourcegroup/README.md
│   ├── main/README.md
│   ├── compute/
│   │   ├── vm.bicep
│   │   └── vm/README.md
│   ├── networking/                # VNet, NSG, ASG, routes, peering, VPN gateway
│   ├── storage/                   # Storage account and blob container
│   ├── security/                  # Key Vault
│   ├── backup/                    # Vault, policy, VM protection
│   ├── monitoring/                # Action groups and metric alerts
│   ├── pim/                       # Eligible Azure RBAC access
│   └── rbac/                      # Direct Azure RBAC assignments
└── README.md                      # Repository overview and process guide
```

See [`modules/README.md`](modules/README.md) for links to the module-specific guides.

## Current module catalogue

| Module area | What it provisions | Key dependencies |
|---|---|---|
| Resource group | Azure resource groups | Subscription and approved region |
| Compute / VM | Windows VM and NIC | Resource group, existing VNet/subnet, optional ASG, Key Vault |
| Networking / VNet | VNet and subnets | Resource group, CIDR plan, optional NSG/route table references |
| Networking / NSG | NSG and security rules | Resource group and approved network rules |
| Networking / ASG | Application Security Group | Resource group |
| Networking / route table | User-defined route table | Resource group and approved route design |
| Networking / peering | Source-to-remote VNet peering | Both VNets and non-overlapping address spaces |
| Networking / VPN gateway | VPN gateway and public IP | Existing VNet and GatewaySubnet |
| Storage | Storage account and blob container | Resource group, globally unique account name |
| Key Vault | Vault with Azure RBAC authorization | Resource group and access-control plan |
| Backup | Recovery Services vault, policy and VM protection | Existing VM/vault/policy in correct deployment order |
| Monitoring | Action group and metric alert | Existing target VM and action group |
| PIM | Eligible Azure RBAC role access | Principal Object ID, role definition ID, authorization to create eligibility requests |
| RBAC | Direct Azure RBAC role assignment | Principal Object ID, role definition ID, authorization to create role assignments |

PIM and direct RBAC are documented as separate modules. They are not currently orchestrated from `modules/main.bicep`.

## Deployment flow

### 1. Environment configuration

The GitHub Actions workflow reads `config/subscriptions.json` and selects entries for `dev`. Each selected entry is expected to provide the subscription ID, environment/application metadata, and a parameter-file path used by the workflow.

The workflow currently logs in using these GitHub repository/environment variables:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`

It uses the subscription ID from the matrix entry for the Azure login.

### 2. Bicep orchestration

`modules/main.bicep` is declared at subscription scope and loops through arrays in the `landingZones` parameter. It can deploy resource groups and invoke child templates for networking, VMs, storage, Key Vault, backup, and monitoring.

The environment parameter file must supply the structure and values expected by `main.bicep`. Review the actual file before running the workflow; the module documentation explains the intended inputs.

### 3. Preview and deployment

The workflow runs:

- `az deployment sub what-if` to preview changes.
- `az deployment sub create` to submit the deployment.

The subscription deployment location is currently set to `eastus` in the workflow. Change this only through a reviewed configuration update if your operational standard requires a different deployment location.

## Prerequisites and configuration

Before using the workflow, ensure:

1. The Azure subscription exists and is the intended target.
2. A Microsoft Entra application/service principal is configured for GitHub Actions workload identity federation (OIDC).
3. `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` are configured as GitHub Actions variables.
4. The federated credential trusts the correct repository and branch/environment subject.
5. The identity has sufficient permissions for every resource type in the deployment. Creating role assignments or PIM eligibility requires specific authorization beyond ordinary Contributor access.
6. The chosen `.bicepparam` file matches the parameters and object structure expected by `modules/main.bicep`.
7. Required resource providers, naming rules, regional availability, quota, and mandatory tags are reviewed.

Do not store real credentials, passwords, client secrets, or other secrets in committed JSON or Bicep parameter files.

## How to run a deployment

The current automated workflow is configured to trigger on a push to the `Dev` branch. Before using it:

1. Review `config/subscriptions.json` and confirm the selected `dev` entry points to the intended subscription and parameter file.
2. Review the parameter file and verify the `landingZones` values.
3. Review the workflow's Azure identity and permissions.
4. Run a Bicep build and inspect the Azure what-if output.
5. Deploy only after the change has been reviewed and approved according to your team's process.
6. Verify the resources in Azure and inspect the GitHub Actions run logs.

For local validation, from the repository root:

```bash
az bicep build --file modules/main.bicep
```

A subscription-level preview can be run with the intended parameter file and a valid deployment location:

```bash
az deployment sub what-if \
  --location eastus \
  --template-file modules/main.bicep \
  --parameters environments/dev.bicepparam
```

Do not copy a production deployment command blindly: check Azure CLI authentication, target subscription, parameter-file syntax, and secure parameter handling first.

## Comparison with the PIKE process diagram

**Overall assessment: partially aligned.** The repository implements the infrastructure-as-code and GitHub Actions deployment portion of the diagram, but it is not yet a full implementation of all 16 business and automation stages.

| PIKE stage in diagram | Repository alignment | Notes |
|---|---|---|
| 1. Requester | Process / external | Not represented in code. |
| 2. Jira request entry | Not implemented in current workflow | No Jira intake integration is present in `.github/workflows/deploy.yml`. |
| 3. Request parameters | Partially implemented | Environment parameter files and `landingZones` carry infrastructure inputs; no Jira payload validation/normalization pipeline is shown. |
| 4. Project assessment | Not implemented as automation | No automated new-vs-existing project decision or foundation branch is present. |
| 5. Environment standard / landing zone | Partially implemented | Resource templates and environment files exist; a centralized enforcement/approval layer is not demonstrated. |
| 6. Cost analysis | Not implemented | No cost estimation or budget approval gate is present. |
| 7. Designated approval | Not implemented as a deployment gate | Current workflow runs what-if and then deploys without a separate approval job/environment gate. |
| 8. Ready for deployment | Not implemented as Jira status trigger | Current trigger is a push to `Dev`, not a Jira Ready-for-Deployment event. |
| 9. Jira automation | Not implemented | No webhook/API intake in the workflow shown. |
| 10. List of Azure resource modules | Implemented in part | Reusable Bicep modules and a main orchestrator exist. |
| 11. GitHub Actions | Implemented in part | Selects dev config, authenticates with OIDC, runs what-if and deployment. Additional request-payload validation and module selection logic need work. |
| 12. Azure target deployment | Implemented in part | Subscription deployment is configured; validate resource scopes, dependencies, and parameter-file compatibility. |
| 13. Mandatory tagging | Partially implemented | Tags are passed to some templates, but universal enforcement and verification across every resource are not demonstrated. |
| 14. Deployment result | Partially implemented | Azure/GitHub Actions reports success/failure, but no structured result payload or resource inventory is sent to Jira. |
| 15. Update request | Not implemented | No Jira ticket update integration is present. |
| 16. Notify requester | Not implemented | No requester email/Jira notification step is present. |
| Monitoring and integration | Partial / TBD | Action groups and metric alert templates exist; external Logic Monitor integration and a centralized monitoring workflow are not present in the deployment workflow. |

## Gaps to close for full alignment

Recommended implementation order:

1. **Request contract:** Define a versioned JSON schema for the Jira request payload, required fields, allowed resource types, approved SKU/OS choices, region, environment, and business/project identifiers.
2. **Jira automation:** Add an authenticated webhook/API entry point that triggers the workflow only when the ticket is in the approved Ready for Deployment state.
3. **Project assessment:** Add an explicit decision and validation for new project vs existing environment, with separate foundation and workload paths.
4. **Standards validation:** Enforce naming, region, SKU, OS image, security baseline, network design, and approved module selection before deployment.
5. **Cost analysis and approval:** Integrate a cost estimation stage and require designated approval before production deployment. Use GitHub Environments or an equivalent controlled approval mechanism as appropriate.
6. **Parameter generation:** Convert the validated request into the exact `.bicepparam`/deployment input shape expected by the selected Bicep modules.
7. **Validation and preview:** Add Bicep build/lint and policy checks, then publish what-if output for review before applying changes.
8. **Secure secret handling:** Generate the VM administrator credential once per deployment, pass the same secure value to preview/deployment where required, and use an approved secret store or secure generation flow. Never log it.
9. **Mandatory tagging:** Define the mandatory tag set (environment, application, project ID, financial ID, business unit/cost center, criticality, resource type, region, owner) and validate coverage consistently. Some Azure resources may require tags at different scopes or have resource-specific support.
10. **Result reporting:** Capture deployment ID, target subscription, resource IDs, status, errors, and timestamps in a structured output.
11. **Jira update and notification:** Update the request ticket and notify the requester after success or failure, with appropriate redaction.
12. **Monitoring integration:** Define alert standards, action-group ownership, diagnostic settings, and the Logic Monitor/external integration.

## Security and operational guidance

- Use GitHub OIDC/workload identity federation instead of long-lived Azure client secrets where possible.
- Separate test and production identities and permissions.
- Use least privilege, especially for RBAC and PIM operations.
- Require an approval gate for production and privileged access changes.
- Treat `what-if` as a review aid, not as an approval control by itself.
- Ensure what-if and actual deployment use the same reviewed inputs.
- Do not commit generated passwords or secrets; avoid printing sensitive values to logs.
- Validate all Bicep files and environment parameter files before deploying.
- Keep the README and module documentation synchronized with changes to the actual workflow and templates.

---

## Related documentation

- [Module documentation index](modules/README.md)
- [Main orchestration template guide](modules/main/README.md)
- [Virtual Machine module guide](modules/compute/vm/README.md)
- [PIM module guide](modules/pim/README.md)
- [Direct RBAC module guide](modules/rbac/README.md)
- [GitHub Actions deployment workflow](.github/workflows/deploy.yml)

**Status:** BIFROST currently provides the core IaC deployment foundation. Jira intake, project assessment, cost/approval gates, mandatory tag enforcement, structured Jira result updates, requester notifications, and external monitoring integration remain additional work for full PIKE process alignment.
