[CmdletBinding()]
param(
    [string]$InputFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'input.json'),
    [string]$PolicyParameterFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'modules/pim/pim-policy-settings.bicepparam'),
    [string]$TemplateFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'modules/pim/pim.bicep'),
    [string]$Location = 'eastus',
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

function Assert-NotPlaceholder([string]$Value, [string]$Field) {
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value -match '^<.*>$') {
        throw "Required field '$Field' is empty or still contains a placeholder."
    }
}

function Invoke-AzChecked([string[]]$Arguments, [string]$Description) {
    Write-Host "==> $Description" -ForegroundColor Cyan
    & az @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Azure CLI failed ($LASTEXITCODE): $Description" }
}

function ConvertTo-DurationSeconds([string]$Value) {
    # Supports the finite ISO 8601 values currently allowed by the Bicep module.
    if ($Value -match '^PT(\d+)H$') { return ([double]$Matches[1] * 3600) }
    if ($Value -match '^P(\d+)D$') { return ([double]$Matches[1] * 86400) }
    if ($Value -match '^P(\d+)W$') { return ([double]$Matches[1] * 7 * 86400) }
    if ($Value -match '^P(\d+)M$') { return ([double]$Matches[1] * 30 * 86400) }
    if ($Value -match '^P(\d+)Y$') { return ([double]$Matches[1] * 365 * 86400) }
    throw "Cannot compare unsupported duration '$Value'."
}

function ConvertTo-PolicyKey([string]$RoleName) {
    return ($RoleName -replace '[^a-zA-Z0-9]', '').ToLowerInvariant()
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { throw 'Azure CLI (az) is not installed or is not on PATH.' }
if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input JSON not found: $InputFile" }
if (-not (Test-Path -LiteralPath $PolicyParameterFile)) { throw "Policy parameter file not found: $PolicyParameterFile" }
if (-not (Test-Path -LiteralPath $TemplateFile)) { throw "Bicep template not found: $TemplateFile" }

try { $request = Get-Content -LiteralPath $InputFile -Raw | ConvertFrom-Json }
catch { throw "Unable to parse input JSON '$InputFile': $($_.Exception.Message)" }

$principalId = [string]$request.pimAccessRequest.requestor.entraObjectId
$access = $request.pimAccessRequest.requestedAccess
$scope = $access.scope
$subscriptionId = [string]$scope.subscriptionId
$roleName = [string]$access.roleName
$roleGuid = [string]$access.roleDefinitionId
$assignmentType = [string]$access.assignmentType
$requestType = [string]$access.requestType
$duration = [string]$access.duration
$justification = [string]$access.justification
$metadata = $request.pimAccessRequest.requestMetadata

Assert-NotPlaceholder $principalId 'pimAccessRequest.requestor.entraObjectId'
Assert-NotPlaceholder ([string]$request.pimAccessRequest.requestor.userPrincipalName) 'pimAccessRequest.requestor.userPrincipalName'
Assert-NotPlaceholder $subscriptionId 'pimAccessRequest.requestedAccess.scope.subscriptionId'
Assert-NotPlaceholder $roleName 'pimAccessRequest.requestedAccess.roleName'
Assert-NotPlaceholder $roleGuid 'pimAccessRequest.requestedAccess.roleDefinitionId'
Assert-NotPlaceholder $justification 'pimAccessRequest.requestedAccess.justification'

if ($scope.type -ne 'Subscription') { throw "This runner currently supports Subscription scope only. scope.type='$($scope.type)'" }
if ($assignmentType -ne 'Eligible') { throw "Only assignmentType='Eligible' is supported by this module. Got '$assignmentType'." }
if ($requestType -ne 'AdminAssign') { throw "For a new eligible assignment, this runner requires requestType='AdminAssign'. Got '$requestType'." }
$allowedDurations = @('PT1H','PT2H','PT3H','PT4H','PT5H','PT6H','PT8H','PT12H','PT24H','P1D','P2D','P3D','P5D','P7D','P10D','P14D','P15D','P21D','P30D','P45D','P60D','P90D','P120D','P180D','P270D','P365D','P1W','P2W','P3W','P4W','P1M','P2M','P3M','P4M','P6M','P9M','P12M','P1Y','P2Y')
if ($duration -notin $allowedDurations) { throw "Unsupported duration '$duration'." }
if ($roleGuid -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') { throw "roleDefinitionId must be a role definition GUID, not a full resource ID. Got '$roleGuid'." }

# Compile the Bicep parameter file so validation uses the actual declared policy values.
$compiledPolicyFile = Join-Path ([System.IO.Path]::GetTempPath()) ("bifrost-policy-{0}.json" -f ([guid]::NewGuid().ToString('N')))
try {
    Invoke-AzChecked @('bicep','build-params','--file',$PolicyParameterFile,'--outfile',$compiledPolicyFile) 'Compile PIM policy parameter file'
    $compiledPolicy = Get-Content -LiteralPath $compiledPolicyFile -Raw | ConvertFrom-Json
}
finally {
    if (Test-Path -LiteralPath $compiledPolicyFile) { Remove-Item -LiteralPath $compiledPolicyFile -Force }
}

$azureRolePolicies = $compiledPolicy.parameters.azureResourcePimPolicy.value
$assignmentDefaults = $compiledPolicy.parameters.pimAssignmentDefaults.value
$policyKey = ConvertTo-PolicyKey $roleName
$matchedPolicyName = $null
$rolePolicy = $null
foreach ($property in $azureRolePolicies.PSObject.Properties) {
    if ((ConvertTo-PolicyKey $property.Name) -eq $policyKey) {
        $matchedPolicyName = $property.Name
        $rolePolicy = $property.Value
        break
    }
}
if ($null -eq $rolePolicy) { throw "POLICY DENIED: Role '$roleName' is not defined in azureResourcePimPolicy. Add an approved role policy entry before requesting access. No deployment was submitted." }
if ($rolePolicy.enabled -ne $true) { throw "POLICY DENIED: Role policy '$matchedPolicyName' is not enabled." }
if ([string]$rolePolicy.roleDefinitionId -ne $roleGuid) { throw "POLICY DENIED: Role '$roleName' roleDefinitionId '$roleGuid' does not match policy ID '$($rolePolicy.roleDefinitionId)'." }
if ($assignmentDefaults.eligibleByDefault -ne $true) { throw 'POLICY DENIED: Policy defaults do not permit eligible assignments.' }
if ((ConvertTo-DurationSeconds $duration) -gt (ConvertTo-DurationSeconds ([string]$assignmentDefaults.maximumEligibilityDuration))) {
    throw "POLICY DENIED: Requested duration '$duration' exceeds maximum '$($assignmentDefaults.maximumEligibilityDuration)'."
}
if (($assignmentDefaults.requireJustification -eq $true -or $rolePolicy.requireJustification -eq $true) -and [string]::IsNullOrWhiteSpace($justification)) {
    throw 'POLICY DENIED: Justification is required by the selected PIM policy.'
}
if (($assignmentDefaults.requireTicketReference -eq $true -or $rolePolicy.requireTicketInformation -eq $true)) {
    Assert-NotPlaceholder ([string]$metadata.ticketNumber) 'pimAccessRequest.requestMetadata.ticketNumber'
    Assert-NotPlaceholder ([string]$metadata.ticketSystem) 'pimAccessRequest.requestMetadata.ticketSystem'
}

Write-Host "POLICY PASSED: '$roleName' matched policy '$matchedPolicyName'." -ForegroundColor Green
Write-Host "Policy maximum eligibility duration: $($assignmentDefaults.maximumEligibilityDuration)"
Write-Host "Requested eligibility duration: $duration"
Write-Host "Policy requires MFA: $($rolePolicy.requireMfa); Conditional Access: $($rolePolicy.requireConditionalAccess); approval: $($rolePolicy.requireApproval)."
Write-Warning 'MFA, Conditional Access, approval, notifications and activation-duration values are policy intent only; this script does not configure or independently verify live Azure PIM policy.'

$roleDefinitionResourceId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/roleDefinitions/$roleGuid"
$deploymentName = "bifrostPimEligibility$(Get-Date -Format 'yyyyMMddHHmmss')"
$requestName = [guid]::NewGuid().ToString()
$startDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

Write-Host "Requestor: $($request.pimAccessRequest.requestor.userPrincipalName)"
Write-Host "Subscription: $subscriptionId"
Write-Host "Role: $roleName ($roleGuid)"
Write-Host "Ticket: $($metadata.ticketSystem) / $($metadata.ticketNumber) / $($metadata.ticketId)"
Write-Host "Request: $requestType | Duration: $duration"

$policyText = Get-Content -LiteralPath $PolicyParameterFile -Raw
$tempParamFile = Join-Path (Split-Path $PolicyParameterFile -Parent) ("pim-request-{0}.bicepparam" -f ([guid]::NewGuid().ToString('N')))
$requestParams = @"

param principalId = '$principalId'
param roleDefinitionId = '$roleDefinitionResourceId'
param requestType = '$requestType'
param justification = '$($justification.Replace("'","''"))'
param duration = '$duration'
param startDateTime = '$startDateTime'
param requestName = '$requestName'
param requestPolicyValidated = true
"@

try {
    Set-Content -LiteralPath $tempParamFile -Value ($policyText.TrimEnd() + $requestParams) -Encoding utf8
    if ($WhatIf) {
        Write-Host 'WhatIf mode: policy validation passed and deployment parameter file generated; no Azure deployment submitted.' -ForegroundColor Yellow
        Write-Host "Generated parameter file: $tempParamFile"
        return
    }

    Invoke-AzChecked @('account','set','--subscription',$subscriptionId) 'Set Azure subscription'
    $account = (& az account show --output json | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to read current Azure account.' }
    if ($account.id -ne $subscriptionId) { throw "Azure CLI subscription mismatch. Expected '$subscriptionId', got '$($account.id)'." }

    Invoke-AzChecked @('deployment','sub','validate','--name',$deploymentName,'--location',$Location,'--parameters',$tempParamFile) 'Validate subscription deployment'
    Invoke-AzChecked @('deployment','sub','create','--name',$deploymentName,'--location',$Location,'--parameters',$tempParamFile,'--output','json') 'Submit PIM eligibility request'
    Write-Host 'PIM eligibility request deployment completed. Check deployment outputs/status in Azure.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $tempParamFile) { Remove-Item -LiteralPath $tempParamFile -Force }
}
