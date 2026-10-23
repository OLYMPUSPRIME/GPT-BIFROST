<p align="center">
<img src="https://img.shields.io/badge/BIFROST-Azure%20Labs-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white" alt="BIFROST Azure Labs"/> <img src="https://img.shields.io/badge/Bicep-Infrastructure%20as%20Code-00A4EF?style=for-the-badge&logo=microsoftazure&logoColor=white" alt="Bicep"/> <img src="https://img.shields.io/badge/GitHub-Actions-181717?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions"/> <img src="https://img.shields.io/badge/Demo-Testing-orange?style=for-the-badge" alt="Demo testing"/>
</p>

# 🌉 BIFROST — Azure VM Deployment & Monitoring Demo

🚀 A repeatable Azure lab to deploy **one Windows VM and one Linux VM** using **Bicep + GitHub Actions**. This is a demo/testing workload, not a production landing zone.

## 🖼️ Architecture at a glance

![BIFROST Azure VM demo architecture](docs/images/bifrost-vm-demo-architecture.svg)

> 🧭 The architecture above is an actual SVG image stored in the repository. Workflow and process diagrams below use Mermaid so they remain editable in Markdown.

## 🎯 Demo goals

- 🪟 Deploy a Windows test virtual machine.
- 🐧 Deploy a Linux test virtual machine.
- 🌐 Create a VNet, subnet, and Network Security Group.
- 🧩 Keep configurable values in a Bicep parameters file; avoid hardcoding environment-specific values in templates.
- 🤖 Validate and deploy through GitHub Actions.
- 🔐 Prefer GitHub OIDC federation for Azure authentication; never commit credentials.
- 📈 Prepare for the next lab: Azure Monitor Agent, Data Collection Rules (DCRs), and alerts.

## 🔁 Target deployment workflow

```mermaid
flowchart TD
    A["🧑‍💻 Update Bicep + parameters"] --> B["🔀 Push branch / open PR"]
    B --> C["🤖 GitHub Actions: build + validate"]
    C --> D{"✅ Review and merge?"}
    D -- "No" --> A
    D -- "Yes" --> E["▶️ Manually start deployment"]
    E --> F["🔐 Azure login using OIDC"]
    F --> G["🔎 What-If preview"]
    G --> H{"👀 Review planned changes"}
    H -- "Stop" --> I["🛑 Do not deploy"]
    H -- "Proceed" --> J["☁️ Deploy Bicep + parameter file"]
    J --> K["🧪 Verify VM, network and outputs"]
    K --> L["📈 Configure Azure Monitor alerts"]
    L --> M["🧹 Delete lab resources when finished"]
```

## ⚙️ GitHub Actions stages

```mermaid
flowchart LR
    A["📥 Checkout"] --> B["🧱 Build Bicep"]
    B --> C["🧾 Validate parameter file"]
    C --> D["🔐 Azure OIDC login"]
    D --> E["🔍 What-If"]
    E --> F["👤 Manual/environment approval"]
    F --> G["🚀 Deploy"]
    G --> H["🔎 Verify outputs"]
    H --> I["📋 Record test results"]
```

## 🛡️ Safety checklist

- 🔒 Use a dedicated test resource group and approved subscription.
- 🌍 Keep region, names, address ranges, VM sizes, image references, and admin username configurable.
- 🔑 Never commit passwords, private keys, tokens, or client secrets.
- 🧱 Restrict RDP (TCP 3389) and SSH (TCP 22) to an approved admin IP/CIDR; never expose them broadly to the internet.
- 💸 Check current VM, disk, public IP, and data-transfer costs before deployment.
- 🧪 Inspect What-If output before applying changes.
- 🧹 Delete test resources when finished.

## 📈 Monitoring target

| Area | Demo validation |
|---|---|
| 🧮 CPU | Confirm metrics; add approved tier-based threshold alerts |
| 🧠 Memory | Configure guest-level collection through Azure Monitor Agent + DCR |
| 💽 Disk | Collect supported guest-level free-space data |
| 💓 Heartbeat | Alert when heartbeat is missing for the approved interval |
| 🌐 Connectivity | Test VM/network and application availability as appropriate |
| 📣 Notifications | Link approved alerts to the Pike Action Group and test delivery |

> ⚠️ Azure platform metrics do not automatically provide every guest-level metric. Memory and guest disk free-space monitoring typically require Azure Monitor Agent, suitable DCRs, and the correct guest performance data source. Confirm the chosen data source and alert-rule type before building the monitoring phase.

## 🌿 Demo branch

`Monitor/Test_1/VMs_Deploy` — test Bicep templates, parameter files, and the GitHub Actions workflow.

## 🧹 Cleanup

After testing, delete the dedicated test resource group only after confirming it contains lab resources only. Verify VMs, disks, public IPs, NICs, VNet, and NSG are removed, and check for any remaining billable resources.

---
<p align="center">🌉 <b>BIFROST</b> · Learn by building · Validate before deploying · Clean up after testing 🧹</p>
