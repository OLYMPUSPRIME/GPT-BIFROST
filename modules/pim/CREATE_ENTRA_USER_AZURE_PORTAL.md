# 👤 Create a Microsoft Entra ID User in the Azure Portal

This guide explains how to create the test user `pim_user_1` through the Azure Portal UI and retrieve the user's **Object ID** for the BIFROST PIM workflow.

> ⚠️ **Important:** Create test users only in an authorized test tenant. Creating an Entra user does **not** automatically grant Azure subscription access. Do not assign permissions without approval.

---

## 🎯 Overview

```mermaid
flowchart TD
    A([🚀 Start]) --> B[🔐 Sign in to Azure Portal]
    B --> C[🏢 Select correct Entra tenant]
    C --> D[👥 Open Microsoft Entra ID → Users]
    D --> E[➕ Create new user]
    E --> F[🆔 Copy user's Object ID]
    F --> G[📝 Update input.json]
    G --> H[🧪 Run PIM workflow with deploy_pim = false]
    H --> I{✅ Validation and What-If successful?}
    I -- No --> J[🛠️ Fix configuration]
    J --> H
    I -- Yes --> K[🔎 Review and obtain approval]
    K --> L[🚦 Run deployment only when authorized]
    L --> M([🏁 Complete])

    classDef startEnd fill:#14532d,stroke:#22c55e,color:#ffffff,stroke-width:2px;
    classDef portal fill:#dbeafe,stroke:#2563eb,color:#172554,stroke-width:2px;
    classDef config fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:2px;
    classDef check fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:2px;
    classDef warning fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:2px;
    class A,M startEnd;
    class B,C,D,E,F portal;
    class G,H,J config;
    class I,K,L check;
```

## ✅ Prerequisites

- 🔑 Access to the correct Microsoft Entra tenant.
- 🛡️ Permission to create users, such as **User Administrator**, or another role with equivalent permissions.
- 🧾 Approved test-user naming convention.
- 🔒 Secure method to provide the temporary password to the test user.

---

## 1. 🏢 Open Microsoft Entra ID

1. Sign in to the [Azure Portal](https://portal.azure.com/).
2. Select the directory/tenant selector in the portal toolbar.
3. Choose the **correct tenant** for BIFROST testing.
4. Search for **Microsoft Entra ID** and open it.
5. Select **Users** from the left navigation.

### Tenant and navigation diagram

```mermaid
flowchart LR
    subgraph Portal["🌐 Azure Portal"]
        A[🔐 Sign in] --> B[🏢 Directory / Tenant selector]
    end

    subgraph Entra["🆔 Microsoft Entra ID"]
        C[👥 Users] --> D[➕ New user]
    end

    B --> C

    classDef portal fill:#dbeafe,stroke:#2563eb,color:#172554,stroke-width:2px;
    classDef entra fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    class A,B portal;
    class C,D entra;
```

---

## 2. ➕ Create the user

1. On the **Users** page, select **New user**.
2. Select **Create new user**.
3. Fill in the user details:

| Field | Example / guidance |
|---|---|
| User principal name (UPN) | `pim_user_1@<your-verified-tenant-domain>` |
| Display name | `BIFROST PIM Test User` |
| Mail nickname | `pim_user_1` |
| Password | Generate a strong temporary password or use the portal-generated option |
| Account enabled | Enable if the test user needs to sign in |

⚠️ Replace `<your-verified-tenant-domain>` with a domain verified in your tenant. Do not copy the placeholder literally.

4. If available, select **Require password change on first sign-in**.
5. Review the details and select **Create**.

### User creation workflow

```mermaid
flowchart TD
    subgraph CreateUser["👤 Create test identity"]
        A[➕ New user] --> B[🧾 Enter UPN and display name]
        B --> C[🔒 Set temporary password]
        C --> D[⚙️ Configure account options]
        D --> E[✅ Review and Create]
    end

    E --> F[🎉 User created]

    classDef input fill:#dbeafe,stroke:#2563eb,color:#172554,stroke-width:2px;
    classDef security fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:2px;
    classDef success fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    class A,B,D input;
    class C security;
    class E,F success;
```

---

## 3. 🆔 Copy the user's Entra Object ID

1. Open the newly created user from the **Users** list.
2. On the user's **Overview** page, locate **Object ID**.
3. Copy the Object ID.

It should look like a GUID:

```text
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### ⚠️ Use the correct identifier

| Identifier | Use in `input.json`? |
|---|---|
| Entra **Object ID** | ✅ Yes |
| User email / UPN | ❌ No |
| Display name | ❌ No |
| Alias (`pim_user_1`) | ❌ No |
| Azure application Client ID | ❌ No |

```mermaid
flowchart LR
    subgraph EntraUser["👤 Entra user profile"]
        A[📛 Display name]
        B[📧 UPN / Email]
        C[🆔 Object ID]
    end

    C --> D[✅ Use Object ID in input.json]
    A -.-> E[❌ Do not use]
    B -.-> E

    classDef correct fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    classDef incorrect fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:2px;
    class C,D correct;
    class A,B,E incorrect;
```

---

## 4. 📝 Update `input.json` in GPT-BIFROST

In repository **`OLYMPUSPRIME/GPT-BIFROST`**, branch **`feature/PIM_mark_1`**, update the user section:

```json
"user": {
  "alias": "pim_user_1",
  "principalId": "PASTE_THE_NEW_USER_OBJECT_ID_HERE",
  "principalType": "User"
}
```

Replace `PASTE_THE_NEW_USER_OBJECT_ID_HERE` with the Object ID copied from Azure Portal. Keep the alias as `pim_user_1` because the current workflow validates that alias.

Commit the updated `input.json` to the intended branch.

---

## 5. 🧪 Validate the PIM workflow

### Recommended first run

1. Open **GitHub → GPT-BIFROST → Actions → PIM Mark-1**.
2. Select branch `feature/PIM_mark_1`.
3. Select **Run workflow**.
4. Set `deploy_pim = false`.
5. Run the workflow.
6. Review validation and What-If output.

### PIM pipeline process

```mermaid
flowchart TD
    subgraph GitHub["🐙 GitHub Actions"]
        A[📄 Read input.json] --> B[🔍 Validate user Object ID and request]
        B --> C[🧱 Build Bicep]
        C --> D[🔐 Azure OIDC login]
        D --> E[🧪 What-If preview]
    end

    E --> F{👀 Preview reviewed and approved?}
    F -- No --> G[🛠️ Fix input or stop]
    G --> A
    F -- Yes --> H[🚦 Authorized deployment run]
    H --> I[🟣 Create PIM eligibility request]

    classDef github fill:#dbeafe,stroke:#2563eb,color:#172554,stroke-width:2px;
    classDef preview fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:2px;
    classDef approval fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:2px;
    classDef deploy fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    class A,B,C,D github;
    class E,G preview;
    class F,H approval;
    class I deploy;
```

> 🚨 Set `deploy_pim = true` only after reviewing the preview, confirming the subscription and scope, and obtaining required authorization.

---

## 6. 🔐 Understand eligibility versus active access

Creating the Entra user only creates the identity. It does **not** give the user Contributor access.

The current workflow requests **Contributor eligibility at subscription scope** for the configured duration (`P90D`, 90 days).

- 🟣 **Eligible:** User is allowed to activate the role under the PIM policy.
- 🟢 **Active:** The user has activated the role and currently has the permissions.
- ⏳ Eligibility does not mean the role is active immediately.
- 🔑 The user must activate the eligible role through the Azure Portal/PIM experience.

```mermaid
flowchart TD
    subgraph Identity["👤 Identity setup"]
        A[➕ Create Entra user] --> B[🆔 Capture Object ID]
    end

    subgraph PIM["🟣 Privileged Identity Management"]
        B --> C[📋 Submit eligibility request]
        C --> D[🟣 Eligible role]
        D --> E[🔑 User activates role]
        E --> F[🟢 Active role for allowed period]
        F --> G[⏳ Role expires / deactivates]
    end

    classDef identity fill:#dbeafe,stroke:#2563eb,color:#172554,stroke-width:2px;
    classDef eligible fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:2px;
    classDef active fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:2px;
    class A,B identity;
    class C,D eligible;
    class E,F,G active;
```

---

## 7. 🧹 Cleanup after testing

When testing is complete:

1. Remove or expire the user's PIM eligibility according to your organization's access-management process.
2. Delete or disable the test user if no longer needed and permitted by tenant policy.
3. Verify that no unintended role assignments remain.
4. Retain ticket and audit records as required.

---

## 📌 Quick checklist

- [ ] Correct Entra tenant selected
- [ ] Test user created successfully
- [ ] User Object ID copied (not UPN/email)
- [ ] `input.json` updated and committed
- [ ] `deploy_pim = false` validation/What-If completed
- [ ] Subscription, role, scope, duration, and ticket reviewed
- [ ] Approval obtained before actual PIM request
- [ ] Test identity and eligibility cleaned up when appropriate
