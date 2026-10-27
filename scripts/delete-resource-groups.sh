#!/usr/bin/env bash
set -Eeuo pipefail
DRY_RUN="${DRY_RUN:-true}"
CONFIRM_DELETE="${CONFIRM_DELETE:-}"
EXPECTED_SUBSCRIPTION_ID="${EXPECTED_SUBSCRIPTION_ID:-}"
for command in az jq; do
  command -v "$command" >/dev/null 2>&1 || { echo "ERROR: Missing command: $command" >&2; exit 1; }
done
[[ -n "$EXPECTED_SUBSCRIPTION_ID" ]] || { echo "ERROR: EXPECTED_SUBSCRIPTION_ID is required." >&2; exit 1; }
ACTUAL_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
if [[ "${ACTUAL_SUBSCRIPTION_ID,,}" != "${EXPECTED_SUBSCRIPTION_ID,,}" ]]; then
  echo "ERROR: Active subscription does not match expected subscription." >&2
  echo "Expected: $EXPECTED_SUBSCRIPTION_ID" >&2
  echo "Actual:   $ACTUAL_SUBSCRIPTION_ID" >&2
  exit 1
fi
echo "TARGET SUBSCRIPTION"
az account show --query "{name:name,id:id,tenantId:tenantId}" -o table
GROUPS_JSON="$(az group list --query '[].{name:name,location:location,id:id}' -o json)"
GROUP_COUNT="$(jq 'length' <<< "$GROUPS_JSON")"
echo "Resource groups discovered: $GROUP_COUNT"
jq -r '.[] | " - (.name) | (.location) | (.id)"' <<< "$GROUPS_JSON"
if [[ "$GROUP_COUNT" -eq 0 ]]; then echo "No resource groups found."; exit 0; fi
if [[ "$DRY_RUN" == "true" ]]; then echo "DRY RUN: nothing deleted."; exit 0; fi
[[ "$DRY_RUN" == "false" ]] || { echo "ERROR: DRY_RUN must be true or false." >&2; exit 1; }
[[ "$CONFIRM_DELETE" == "DELETE-ALL-RESOURCE-GROUPS" ]] || { echo "ERROR: Exact confirmation phrase is required." >&2; exit 1; }
echo "WARNING: Deleting all $GROUP_COUNT resource groups in $ACTUAL_SUBSCRIPTION_ID."
FAILED=0
while IFS= read -r GROUP_NAME; do
  [[ -n "$GROUP_NAME" ]] || continue
  echo "Deleting resource group: $GROUP_NAME"
  if az group delete --name "$GROUP_NAME" --subscription "$ACTUAL_SUBSCRIPTION_ID" --yes; then
    echo "Deletion completed: $GROUP_NAME"
  else
    echo "ERROR: Failed to delete $GROUP_NAME" >&2
    FAILED=1
  fi
done < <(jq -r '.[].name' <<< "$GROUPS_JSON")
if [[ "$FAILED" -ne 0 ]]; then echo "One or more deletions failed. Check logs and Azure Activity Log." >&2; exit 1; fi
echo "All deletion commands completed. Verify final state in Azure Portal."
