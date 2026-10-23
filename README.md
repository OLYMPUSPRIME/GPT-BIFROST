# BIFROST

Azure networking, infrastructure, and cloud operations learning labs.

BIFROST contains practical Azure demonstrations and testing exercises built with Infrastructure as Code. Each lab focuses on reproducible deployments, validation, and documented results.

## Target deployment workflow

This workflow uses Bicep to define two test virtual machines—one Windows and one Linux—and the supporting network resources. GitHub Actions validates the templates, previews changes, and deploys only when manually triggered.

```mermaid
flowchart TD
    DEV["Developer updates Bicep or parameters"]
    PR["Pull request"]
    VALIDATE["GitHub Actions: Bicep build and parameter validation"]
    MAIN["Merge reviewed change to main"]
    RUN["Manually run deployment workflow"]
    AUTH["Authenticate to Azure with OIDC"]
    WHATIF["Azure deployment What-If"]
    DEPLOY["Deploy Bicep + parameter file"]
    RES["Dedicated Azure resource group"]
    WIN["Windows test VM"]
    LIN["Linux test VM"]
    VERIFY["Verify deployment outputs and connectivity"]
    NEXT["Next phase: Azure Monitor and alert rules"]

    DEV --> PR --> VALIDATE --> MAIN --> RUN
    RUN --> AUTH --> WHATIF --> DEPLOY --> RES
    RES --> WIN
    RES --> LIN
    WIN --> VERIFY
    LIN --> VERIFY
    VERIFY --> NEXT
```

## GitHub Actions deployment stages

```mermaid
flowchart LR
    CHECKOUT["Checkout"]
    BUILD["Build Bicep"]
    PARAMS["Validate .bicepparam"]
    LOGIN["Azure OIDC login"]
    PREVIEW["What-If preview"]
    APPROVAL["Environment approval"]
    APPLY["Deploy resources"]
    CHECK["Verify outputs"]

    CHECKOUT --> BUILD --> PARAMS
    PARAMS --> LOGIN --> PREVIEW --> APPROVAL --> APPLY --> CHECK
```

The test VM deployment is maintained in the `Monitor/Test_1/VMs_Deploy` branch. Use a dedicated test resource group, restrict RDP/SSH to a trusted administrator CIDR, keep credentials in GitHub Secrets, and review Azure costs before deployment. Delete test resources when they are no longer needed.
