# 📚 BIFROST documentation hub

Welcome to the BIFROST Azure PIM operator/requester docs.

## 🧭 Guides

| Document | What it covers |
|---|---|
| [CLI_LOCAL_TESTING.md](CLI_LOCAL_TESTING.md) | Azure CLI login, compile, validation, and testing. |
| [CREATE_ENTRA_USER_AZURE_PORTAL.md](CREATE_ENTRA_USER_AZURE_PORTAL.md) | Create an Entra user and collect identity IDs. |
| [PIM_AZURE_PORTAL_VARIABLES.md](PIM_AZURE_PORTAL_VARIABLES.md) | Portal locations for request, role, scope, approver, and OIDC values. |
| [hardcoded_values_audit.md](hardcoded_values_audit.md) | Review hardcoded/default values and external inputs. |

## 🧩 Which file is responsible for what?

```mermaid
flowchart TB
  subgraph Request["🧾 Requester input"]
    INPUT[input.json]
  end
  subgraph Policies["🛡️ PIM policy configuration"]
    PARAM[pim-policy-settings.bicepparam]
  end
  subgraph Deployment["⚙️ Azure Resource PIM deployment"]
    BICEP[pim.bicep]
    RESULT[Eligibility schedule]
  end
  INPUT -->|Must be mapped by runner| BICEP
  PARAM -. Policy settings are intent currently .-> BICEP
  BICEP --> RESULT

  classDef req fill:#E3F2FD,stroke:#1565C0,color:#0D47A1,stroke-width:2px;
  classDef pol fill:#F3E5F5,stroke:#7B1FA2,color:#4A148C,stroke-width:2px;
  classDef dep fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20,stroke-width:2px;
  class INPUT req;
  class PARAM pol;
  class BICEP,RESULT dep;
```

## 🚦 Implementation status

The current template creates Azure Resource PIM eligibility. Policy settings are not automatically enforced; Entra directory-role and PIM for Groups policy updates require separate API implementation. Root JSON is not read automatically by Bicep.

For architecture and constraints, see [root README](../README.md) and [module README](../modules/pim/README.md).
