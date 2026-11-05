[CmdletBinding(SupportsShouldProcess = $true)]
param([string]$InputFile = './input.json', [switch]$WhatIf)
$ErrorActionPreference = 'Stop'
function Assert-Value([string]$Value, [string]$Field) {
  if ([string]::IsNullOrWhiteSpace($Value) -or $Value -match 'REPLACE_WITH') { throw "Required field '$Field' is empty or placeholder." }
}
if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input file not found: $InputFile" }
$request = Get-Content -LiteralPath $InputFile -Raw | ConvertFrom-Json
foreach ($field in @('tenantId','subscriptionId','principalId','roleDefinitionGuid','scopeLevel','roleName','justification','ticketNumber','ticketSystem')) { Assert-Value ([string]$request.$field) $field }
if ($request.scopeLevel -notin @('Subscription','ResourceGroup','Resource')) { throw 'scopeLevel must be Subscription, ResourceGroup, or Resource.' }
if ($request.principalType -notin @('User','Group','ServicePrincipal')) { throw 'principalType must be User, Group, or ServicePrincipal.' }
if ($request.roleDefinitionGuid -notmatch '^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') { throw 'roleDefinitionGuid must be a GUID.' }
if ($request.scopeLevel -eq 'ResourceGroup') { Assert-Value ([string]$request.resourceGroupName) 'resourceGroupName' }
if ($request.scopeLevel -eq 'Resource') {
  Assert-Value ([string]$request.resourceId) 'resourceId'
  if ($request.resourceId -notmatch '^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/[^/]+/.+') { throw 'resourceId must be a full ARM resource ID.' }
}
if (-not $WhatIf) {
  & az account set --subscription $request.subscriptionId
  if ($LASTEXITCODE -ne 0) { throw 'Could not set Azure subscription.' }
  $account = (& az account show --output json | ConvertFrom-Json)
  if ($account.tenantId -ne $request.tenantId) { throw 'Azure CLI tenant differs from tenantId in input.json.' }
}
$scope = switch ($request.scopeLevel) {
  'Subscription' { "/subscriptions/$($request.subscriptionId)" }
  'ResourceGroup' { "/subscriptions/$($request.subscriptionId)/resourceGroups/$($request.resourceGroupName)" }
  'Resource' { [string]$request.resourceId }
}
$roleId = "/subscriptions/$($request.subscriptionId)/providers/Microsoft.Authorization/roleDefinitions/$($request.roleDefinitionGuid)"
Write-Host "Request: $($request.roleName) => $($request.principalId) at $scope" -ForegroundColor Cyan
Write-Host "Ticket: $($request.ticketSystem) $($request.ticketNumber) | Environment: $($request.environment)"
if ($WhatIf) { Write-Host 'WHATIF: no RBAC assignment created.' -ForegroundColor Yellow; exit 0 }
if (-not $PSCmdlet.ShouldProcess($scope, "Assign $($request.roleName) to $($request.principalId)")) { exit 0 }
& az role definition list --name $request.roleDefinitionGuid --scope $scope --output json
if ($LASTEXITCODE -ne 0) { throw 'Could not validate role definition at requested scope.' }
& az role assignment create --assignee-object-id $request.principalId --assignee-principal-type $request.principalType --role $roleId --scope $scope --name ([guid]::NewGuid().Guid) --output json
if ($LASTEXITCODE -ne 0) { throw 'Azure RBAC role assignment failed.' }
Write-Host 'RBAC assignment created.' -ForegroundColor Green
