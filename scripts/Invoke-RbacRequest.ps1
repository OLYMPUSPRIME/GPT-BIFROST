[CmdletBinding(SupportsShouldProcess = $true)]
param([string]$InputFile = './input.json', [switch]$WhatIf)
$ErrorActionPreference = 'Stop'

function Assert-Value([string]$Value, [string]$Field) {
  if ([string]::IsNullOrWhiteSpace($Value) -or $Value -match 'REPLACE_WITH') {
    throw "Required field '$Field' is empty or placeholder."
  }
}

if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input file not found: $InputFile" }
$request = Get-Content -LiteralPath $InputFile -Raw | ConvertFrom-Json
foreach ($field in @('environment','tenantId','subscriptionId','principalId','roleDefinitionGuid','scopeLevel','roleName','justification','ticketNumber','ticketSystem')) {
  Assert-Value ([string]$request.$field) $field
}
if ($request.scopeLevel -notin @('Subscription','ResourceGroup','Resource')) { throw 'scopeLevel must be Subscription, ResourceGroup, or Resource.' }
if ($request.principalType -notin @('User','Group','ServicePrincipal')) { throw 'principalType must be User, Group, or ServicePrincipal.' }
if ($request.roleDefinitionGuid -notmatch '^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') { throw 'roleDefinitionGuid must be a GUID.' }
if ($request.scopeLevel -eq 'ResourceGroup') { Assert-Value ([string]$request.resourceGroupName) 'resourceGroupName' }
if ($request.scopeLevel -eq 'Resource') {
  Assert-Value ([string]$request.resourceId) 'resourceId'
  if ($request.resourceId -notmatch '^/subscriptions/([^/]+)/resourceGroups/([^/]+)/providers/([^/]+)/(.+)$') { throw 'resourceId must be a full ARM ID for an individual resource.' }
  if ($Matches[1] -ne $request.subscriptionId) { throw 'resourceId subscription does not match subscriptionId in input.json.' }
}

$scope = switch ($request.scopeLevel) {
  'Subscription' { "/subscriptions/$($request.subscriptionId)" }
  'ResourceGroup' { "/subscriptions/$($request.subscriptionId)/resourceGroups/$($request.resourceGroupName)" }
  'Resource' { [string]$request.resourceId }
}
Write-Host "Request: $($request.roleName) => $($request.principalId) at $scope" -ForegroundColor Cyan
Write-Host "Ticket: $($request.ticketSystem) $($request.ticketNumber) | Environment: $($request.environment)"
Write-Host 'This workflow only assigns access to an existing target; it does not provision infrastructure.'

if ($WhatIf) { Write-Host 'WHATIF: input validated; no Azure access or RBAC assignment performed.' -ForegroundColor Yellow; exit 0 }

& az account set --subscription $request.subscriptionId
if ($LASTEXITCODE -ne 0) { throw 'Could not set Azure subscription.' }
$account = (& az account show --output json | ConvertFrom-Json)
if ($account.tenantId -ne $request.tenantId) { throw 'Azure CLI tenant differs from tenantId in input.json.' }

# Check target existence before assigning access; do not create target resources.
switch ($request.scopeLevel) {
  'Subscription' { }
  'ResourceGroup' {
    & az group show --name $request.resourceGroupName --subscription $request.subscriptionId --output none
    if ($LASTEXITCODE -ne 0) { throw "Existing resource group '$($request.resourceGroupName)' not found or inaccessible. No assignment made." }
  }
  'Resource' {
    & az resource show --ids $request.resourceId --subscription $request.subscriptionId --output none
    if ($LASTEXITCODE -ne 0) { throw "Existing resource '$($request.resourceId)' not found or inaccessible. No assignment made." }
  }
}
$roleId = "/subscriptions/$($request.subscriptionId)/providers/Microsoft.Authorization/roleDefinitions/$($request.roleDefinitionGuid)"
& az role definition list --name $request.roleDefinitionGuid --scope $scope --output json
if ($LASTEXITCODE -ne 0) { throw 'Could not validate role definition at requested scope. No assignment made.' }

if (-not $PSCmdlet.ShouldProcess($scope, "Assign $($request.roleName) to $($request.principalId)")) { exit 0 }

# Stable name avoids random assignment IDs on repeated runs for the same scope/principal/role/request key.
$assignmentSeed = "$scope|$($request.principalId)|$roleId|$($request.assignmentId)"
$hash = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($assignmentSeed))
$assignmentGuid = [guid]::new([byte[]]$hash[0..15]).Guid
$cliArgs = @('role','assignment','create','--assignee-object-id',$request.principalId,'--assignee-principal-type',$request.principalType,'--role',$roleId,'--scope',$scope,'--name',$assignmentGuid,'--output','json')
if (-not [string]::IsNullOrWhiteSpace([string]$request.condition)) {
  $cliArgs += @('--condition',[string]$request.condition,'--condition-version',[string]$request.conditionVersion)
}
& az @cliArgs
if ($LASTEXITCODE -ne 0) { throw 'Azure RBAC role assignment failed.' }
Write-Host 'RBAC assignment created at the exact requested scope.' -ForegroundColor Green
