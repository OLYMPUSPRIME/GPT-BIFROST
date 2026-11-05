# 🌌 BIFROST PIM — Beginner Demo Guide

> **Audience:** Someone new to the repository and Azure PIM.  
> **Goal:** Explain the project, prepare Azure, validate a request, submit eligible access, and verify it in Azure Portal.

⚠️ **Current scope:** This branch creates Azure Resource PIM eligibility at **subscription scope only**. The policy file is currently used for local pre-deployment validation; it does not automatically configure or verify every live Azure PIM setting.

## 1. What is BIFROST?

BIFROST automates a request for **Privileged Identity Management (PIM) eligible access** using:

- 📄 **JSON** — the access request (who, role, scope, duration, ticket).
- 🛡️ **Bicep parameter file** — policy intent used by the validator.
- 🐚 **PowerShell** — reads request and policy, validates them, and coordinates Azure CLI.
- 📦 **Bicep** — describes the Azure Resource PIM eligibility schedule request.
- ☁️ **Azure CLI** — validates and submits the deployment.

**Simple explanation:** JSON says what access is requested; the policy file says what the local validator allows. PowerShell checks the request before Azure deployment.

## 2. Repository tour

~~~text
BIFROST/
├── input.json
├── scripts/
│   └── Invoke-PimRequest.ps1
├── modules/
│   └── pim/
│       ├── pim.bicep
│       ├── pim-policy-settings.bicepparam
│       └── README.md
└── docs/
    ├── BIFROST_PIM_DEMO_GUIDE.md  # This guide
    ├── CLI_LOCAL_TESTING.md
    └── PIM_REQUEST_FLOW.md
~~~

| File | What it does |
|---|---|
| input.json | Requestor, role, subscription, duration, justification, ticket |
| pim-policy-settings.bicepparam | Local role policy and assignment defaults |
| Invoke-PimRequest.ps1 | Reads and validates request/policy; calls Azure CLI |
| pim.bicep | Creates the Azure Resource PIM eligibility schedule request |
| README.md | Repository overview |

### Architecture overview

~~~mermaid
flowchart TB
  subgraph Request["🧾 Request layer"]
    JSON["📄 input.json<br/>User, role, scope, duration, ticket"]
  end
  subgraph Policy["🛡️ Policy validation"]
    PARAM["📘 PIM policy .bicepparam"]
    COMPILE["⚙️ az bicep build-params"]
    PS["🐚 PowerShell runner<br/>Validate request vs policy"]
    PARAM --> COMPILE --> PS
  end
  subgraph Azure["🚀 Azure deployment"]
    TEMP["Temporary request .bicepparam"]
    VALIDATE["🔎 Azure deployment validate"]
    CREATE["🚀 Azure deployment create"]
    BICEP["📦 pim.bicep"]
    PIM["🔐 PIM eligibility schedule"]
    TEMP --> VALIDATE --> CREATE --> BICEP --> PIM
  end
  JSON --> PS
  PS -->|Policy denied| STOP["⛔ Stop; no deployment"]
  PS -->|Policy passed| TEMP
  classDef request fill:#E3F2FD,stroke:#1565C0,color:#0D47A1,stroke-width:2px;
  classDef policy fill:#F3E5F5,stroke:#7B1FA2,color:#4A148C,stroke-width:2px;
  classDef runner fill:#FFF3E0,stroke:#EF6C00,color:#E65100,stroke-width:2px;
  classDef deploy fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20,stroke-width:2px;
  classDef deny fill:#FFEBEE,stroke:#C62828,color:#B71C1C,stroke-width:2px;
  class JSON request;
  class PARAM,COMPILE policy;
  class PS runner;
  class TEMP,VALIDATE,CREATE,BICEP,PIM deploy;
  class STOP deny;
~~~

## 3. Where do I run it?

### Recommended: clone the repository and run locally

**Clone the repo to your laptop and run commands from the local checkout.**

- GitHub displays and stores the source code.
- Your laptop runs PowerShell, Azure CLI, and Bicep.
- Azure Portal is used to prepare and verify Azure.
- A GitHub Markdown page does not execute commands.

You do not need to download individual files. Cloning preserves the directory structure and relative file paths.

### Clone using Git

Open PowerShell:

~~~powershell
git --version
git clone https://github.com/PROMETHEUS-N/BIFROST.git
cd BIFROST
git fetch origin
git checkout feature/PIM_mark_2
git pull origin feature/PIM_mark_2
git branch --show-current
git status
~~~

Expected branch: **feature/PIM_mark_2**.

If the repository is private, authenticate with GitHub using your approved method.

### Alternative: download ZIP

1. Open the GitHub repo and select branch **feature/PIM_mark_2**.
2. Select **Code → Download ZIP**.
3. Extract the ZIP on your computer.
4. Open PowerShell in the extracted repo folder.

ZIP works for a one-time demo, but cloning is better for branch updates and development.

## 4. Install and check tools

Run PowerShell 7 (**pwsh**) from the repository root.

~~~powershell
git --version
pwsh --version
az version
az bicep install
az bicep version
~~~

Check files exist:

~~~powershell
Test-Path .\input.json
Test-Path .\scripts\Invoke-PimRequest.ps1
Test-Path .\modules\pim\pim.bicep
Test-Path .\modules\pim\pim-policy-settings.bicepparam
~~~

All should return **True**.

## 5. Azure Portal preparation — before demo day

Do these steps in advance. Avoid changing privileged settings live during the presentation.

### 5.1 Confirm tenant and subscription

1. Sign in to [Azure Portal](https://portal.azure.com).
2. Open **Microsoft Entra ID → Overview** and note the Tenant ID.
3. Open **Subscriptions** and select the demo subscription.
4. Note the Subscription ID.
5. Confirm this is a non-production/demo subscription.

### 5.2 Confirm PIM resource onboarding

1. Search for **Privileged Identity Management**.
2. Open **Azure resources**.
3. Find the demo subscription.
4. If absent, use **Discover resources** if available and follow your organization's onboarding process.
5. Confirm the subscription appears under Azure resources.

If you cannot onboard it, ask an Azure administrator to do this beforehand.

### 5.3 Review live PIM role settings

1. Open **Privileged Identity Management → Azure resources**.
2. Select the demo subscription.
3. Open **Settings / Role settings** (labels can change).
4. Select the role being demonstrated.
5. Review activation duration, MFA, Conditional Access, justification, approval/approvers, and notifications.

⚠️ Values in the local .bicepparam file do **not** automatically configure live Azure PIM. Configure and verify live settings separately if your demo needs to show those controls.

### 5.4 Azure permissions to arrange

Ask the subscription/tenant administrator to confirm your CLI identity has:

- Access to the target subscription.
- Permission to submit Azure Resource PIM role eligibility schedule requests for the selected role/scope.
- Permission to view the resulting PIM eligibility assignment.
- Additional permissions for PIM onboarding or role-settings changes, if you are performing those tasks.

**Do not assume Azure Contributor is sufficient** for privileged role eligibility requests. Have an administrator confirm the exact least-privilege permissions for your tenant and operation. If approval is enabled, make sure the required approver is configured and available.

### 5.5 Identify the recipient user

1. Azure Portal → **Microsoft Entra ID → Users**.
2. Open the intended demo recipient.
3. Copy Display Name, UPN, and Object ID.
4. Verify that this is a dedicated test identity where possible.

Avoid granting powerful roles to your everyday or production identity.

## 6. Values needed for the CLI

| Value | Example format | Where to find it |
|---|---|---|
| Tenant ID | UUID | Entra ID → Overview |
| Subscription ID | UUID | Azure → Subscriptions |
| Recipient UPN | demo.user@contoso.com | Entra ID → Users |
| Recipient Object ID | UUID | Entra ID → Users → Object ID |
| Role name | Owner / User Access Administrator | Policy file |
| Role definition GUID | UUID | Policy file / Azure role definition |
| Duration | P30D | Request, subject to policy maximum |
| Justification | Text | Demo request |
| Ticket number | DEMO-123 | Ticketing system |
| Ticket system | Jira / ServiceNow | Ticketing system |

### PowerShell variables (for CLI checks)

~~~powershell
$TenantId = "<TENANT_ID>"
$SubscriptionId = "<SUBSCRIPTION_ID>"
$RecipientUPN = "<RECIPIENT_UPN>"
$RecipientObjectId = "<RECIPIENT_OBJECT_ID>"
$RoleName = "Owner"
$RoleGuid = "8e3af657-a8ff-443c-a75c-2fe8c4bcb635"
$Duration = "P30D"
$Location = "eastus"
~~~

Replace placeholders. These shell variables are for environment checks; **the current runner reads request values from input.json**, not from these variables.

## 7. Azure CLI login and checks

### 7.1 Login to the correct tenant

~~~powershell
az login --tenant $TenantId
~~~

Complete the browser sign-in.

### 7.2 List subscriptions

~~~powershell
az account list --output table
~~~

### 7.3 Set subscription

~~~powershell
az account set --subscription $SubscriptionId
~~~

### 7.4 Verify context

~~~powershell
az account show --output json
~~~

Check tenant ID, subscription ID, subscription name, and signed-in user. Stop if they are wrong.

### 7.5 Verify recipient identity

~~~powershell
az ad user show --id $RecipientUPN --query "{displayName:displayName,upn:userPrincipalName,id:id}" --output json
~~~

Check the returned Object ID against the value you copied from Portal and the JSON file.

### 7.6 Verify role definition

~~~powershell
az role definition list --name $RoleGuid --query "[].{Name:roleName,Id:name}" --output table
~~~

Confirm the role name and GUID.

## 8. Prepare input.json

Open the root input.json in VS Code or another editor. Use the existing schema and replace placeholders.

Example request (preserve the existing top-level configurationPurpose field in your actual file):

~~~json
{
  "configurationPurpose": "BIFROST demo request input",
  "pimAccessRequest": {
    "requestor": {
      "displayName": "<RECIPIENT_DISPLAY_NAME>",
      "userPrincipalName": "<RECIPIENT_UPN>",
      "entraObjectId": "<RECIPIENT_OBJECT_ID>"
    },
    "requestedAccess": {
      "platform": "AzureResource",
      "roleName": "Owner",
      "roleDefinitionId": "8e3af657-a8ff-443c-a75c-2fe8c4bcb635",
      "scope": {
        "type": "Subscription",
        "subscriptionId": "<SUBSCRIPTION_ID>",
        "resourceGroupName": "",
        "resourceId": ""
      },
      "assignmentType": "Eligible",
      "requestType": "AdminAssign",
      "duration": "P30D",
      "justification": "BIFROST demo - eligible access request"
    },
    "requestMetadata": {
      "requestedBy": "<REQUESTER_UPN>",
      "environment": "dev",
      "ticketId": "<TICKET_ID>",
      "ticketNumber": "<TICKET_NUMBER>",
      "ticketSystem": "<TICKET_SYSTEM>"
    }
  }
}
~~~

### Current policy roles

Current Azure Resource role policy entries include:

- **Owner** — GUID 8e3af657-a8ff-443c-a75c-2fe8c4bcb635
- **User Access Administrator** — GUID 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9

The sample JSON currently requests Contributor, which is not configured and should be denied. For a successful demo, use a role configured in the policy and approved for the test subscription. Owner is highly privileged—use it only in a dedicated, approved test environment.

Do not change only the JSON to bypass policy. Add a policy entry only after review/approval.

### Validate JSON syntax

~~~powershell
Get-Content .\input.json -Raw | ConvertFrom-Json | Out-Null
Write-Host "JSON syntax is valid"
~~~

## 9. What policy validation does

The runner compiles the .bicepparam policy file to JSON, then checks:

1. Required request fields are present and are not placeholders.
2. Scope is Subscription (the only scope currently supported).
3. Assignment type is Eligible.
4. Request type is AdminAssign.
5. The role exists in the policy.
6. The role policy is enabled.
7. The role definition GUID matches exactly.
8. Duration is supported and does not exceed the configured maximum.
9. Justification is present when required.
10. Ticket number and ticket system are present when required.

~~~mermaid
flowchart TD
  START(["▶️ Start runner"]) --> READ["📄 Read input.json"]
  READ --> POLICY["📘 Compile/read policy file"]
  POLICY --> ROLE{"Role policy exists?"}
  ROLE -->|No| DENY["⛔ Reject: no deployment"]
  ROLE -->|Yes| ENABLED{"Enabled?"}
  ENABLED -->|No| DENY
  ENABLED -->|Yes| GUID{"Role GUID matches?"}
  GUID -->|No| DENY
  GUID -->|Yes| SCOPE{"Subscription + Eligible + AdminAssign?"}
  SCOPE -->|No| DENY
  SCOPE -->|Yes| DURATION{"Duration within maximum?"}
  DURATION -->|No| DENY
  DURATION -->|Yes| META{"Required justification/ticket present?"}
  META -->|No| DENY
  META -->|Yes| PASS["✅ Policy validation passes"]
  PASS --> DEPLOY["➡️ Continue to Azure deployment"]
  classDef good fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20,stroke-width:2px;
  classDef bad fill:#FFEBEE,stroke:#C62828,color:#B71C1C,stroke-width:2px;
  classDef check fill:#E3F2FD,stroke:#1565C0,color:#0D47A1,stroke-width:2px;
  class START,READ,POLICY,SCOPE,DURATION,META,GUID,ROLE,ENABLED check;
  class PASS,DEPLOY good;
  class DENY bad;
~~~

## 10. Demo commands — run in this order

Run these commands **from the repository root**.

### Step 1 — Compile Bicep

~~~powershell
az bicep build --file .\modules\pim\pim.bicep
~~~

Expected: successful compilation.

### Step 2 — Safe policy preview

~~~powershell
pwsh .\scripts\Invoke-PimRequest.ps1 -WhatIf
~~~

Expected: request is checked against policy and a temporary parameter file is generated. No Azure deployment is submitted.

⚠️ Current -WhatIf is a policy validation/parameter generation preview. It does not run Azure deployment validation.

### Step 3 — Negative test: demonstrate rejection

Temporarily request an unconfigured role (Contributor in the current policy setup), using its correct role GUID.

~~~powershell
pwsh .\scripts\Invoke-PimRequest.ps1 -WhatIf
~~~

Expected: **POLICY DENIED**; no Azure deployment submitted.

Restore the approved role in input.json and save the file afterwards.

### Step 4 — Preview approved request again

~~~powershell
pwsh .\scripts\Invoke-PimRequest.ps1 -WhatIf
~~~

Expected: policy checks pass.

### Step 5 — Submit the actual request

⚠️ This is a real deployment command. Verify tenant, subscription, recipient, role, duration, justification, and ticket first.

~~~powershell
pwsh .\scripts\Invoke-PimRequest.ps1
~~~

The runner will validate the policy, select the subscription from the JSON, run Azure deployment validation, and submit the deployment.

### Sequence diagram

```mermaid
sequenceDiagram
  autonumber
  actor Presenter as 🧑‍💻 Presenter
  participant Runner as 🐚 PowerShell
  participant Input as 📄 input.json
  participant Policy as 🛡️ Policy file
  participant CLI as ☁️ Azure CLI
  participant ARM as 🏗️ Azure Resource Manager
  participant PIM as 🔐 Azure PIM

  Presenter->>Runner: Run Invoke-PimRequest.ps1
  Runner->>Input: Read request
  Runner->>Policy: Compile/load policy
  Policy-->>Runner: Policy values
  Runner->>Runner: Validate request
  alt Policy fails
    Runner-->>Presenter: POLICY DENIED; stop
  else Policy passes
    Runner->>Runner: Create temporary parameters
    Runner->>CLI: Set and verify subscription
    Runner->>CLI: deployment sub validate
    CLI->>ARM: Validate template
    ARM-->>CLI: Validation result
    Runner->>CLI: deployment sub create
    CLI->>ARM: Submit deployment
    ARM->>PIM: Create eligibility request
    PIM-->>Presenter: Result
  end
```

## 11. Verify in Azure Portal

After the actual command completes:

1. Open Azure Portal.
2. Navigate to **Privileged Identity Management → Azure resources**.
3. Select the same subscription used in input.json.
4. Open **Assignments / Eligible assignments** (portal labels can vary).
5. Search for the recipient user.
6. Confirm the role and scope.
7. Inspect eligibility details and expiration, if displayed.
8. If it is not visible, inspect the Azure CLI deployment result and refresh the portal.

Explain: **Eligibility is not active access.** The user must activate the role separately, subject to live Azure PIM settings.

## 12. Demo narration

**Introduction**

> “BIFROST automates Azure PIM eligible access requests. Request data and policy are kept separate. The script validates the request, and then Bicep/Azure CLI submits it.”

**Repository tour**

> “input.json describes the request. The policy parameter file contains local policy intent. PowerShell connects the two. Bicep describes the Azure eligibility resource.”

**Validation**

> “The role must be present and enabled in policy, and the role ID, duration, justification, and ticket details must comply.”

**Negative test**

> “An unconfigured role is rejected before Azure deployment. This is the fail-closed behavior.”

**Successful request**

> “After policy validation passes, Azure CLI validates and submits the deployment. I’ll verify the eligible assignment in Azure Portal.”

**Closing**

> “The same PowerShell runner can be reused locally and from GitHub Actions after Azure authentication. The Actions workflow and OIDC configuration are still separate work.”

## 13. Troubleshooting

| Error/problem | Likely cause | Resolution |
|---|---|---|
| az not found | Azure CLI missing/PATH | Install CLI, reopen PowerShell, run az version |
| pwsh not found | PowerShell 7 missing | Install PowerShell 7 |
| Wrong subscription | CLI context mismatch | Run az account list, set subscription, verify |
| JSON parse error | Invalid JSON | Run ConvertFrom-Json check |
| Placeholder error | Values still like <...> | Populate required fields |
| Policy not found | Role not configured | Add approved role policy entry after review |
| Role GUID mismatch | Incorrect role GUID | Verify Azure role definition |
| Duration exceeds max | Requested duration too long | Use duration within policy maximum |
| Missing ticket/justification | Required input missing | Fill JSON fields |
| Authorization error | Azure identity lacks required PIM permission | Ask administrator to verify access |
| Deployment validation error | Bicep/API/parameter/permission issue | Read CLI error and deployment details |
| Assignment not visible | Wrong subscription, failed deployment, portal delay | Verify deployment and refresh portal |

## 14. Current implementation boundaries

### Implemented

- JSON request input.
- Azure Resource role policy configuration.
- PowerShell request/policy checks.
- Subscription-scoped Azure Resource PIM eligibility request.
- Azure CLI deployment validation and submission.
- Local runner that can be reused in a future workflow.

### Not implemented

- Applying MFA, Conditional Access, approval, notification, and activation settings from the policy file to live Azure PIM.
- Querying live Azure PIM policy and comparing it with local policy.
- Entra directory-role PIM policy updates (Graph).
- PIM for Groups policy updates (Graph).
- Resource Group or individual resource scope.
- Jira/ServiceNow integration.
- GitHub Actions workflow.

The policy validation is a pre-deployment guardrail. It does not mean every local policy value is enforced by Azure.

## 15. Demo-day checklist

- [ ] Correct branch checked out: feature/PIM_mark_2
- [ ] Repo cloned/extracted locally; PowerShell opened at repo root
- [ ] PowerShell 7, Azure CLI, Bicep available
- [ ] Correct tenant and subscription confirmed
- [ ] Azure PIM resource onboarding confirmed
- [ ] Required permissions verified with administrator
- [ ] Recipient user/Object ID verified
- [ ] Role and role GUID verified
- [ ] JSON placeholders replaced and syntax valid
- [ ] Selected role is present in policy
- [ ] Preview passes
- [ ] Negative test prepared
- [ ] I understand the actual command submits a real request
- [ ] Portal open at correct subscription for verification

## 📚 Related docs

- [Root README](../README.md)
- [Local CLI testing](CLI_LOCAL_TESTING.md)
- [PIM request flow](PIM_REQUEST_FLOW.md)
- [Docs index](README.md)
