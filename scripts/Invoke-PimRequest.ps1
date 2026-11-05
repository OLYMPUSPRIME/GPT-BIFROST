[CmdletBinding()]
param(
    [string]$InputFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'input.json'),
    [string]$PolicyParameterFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'modules/pim/pim-policy-settings.bicepparam'),
    [string]$TemplateFile = (Join-Path (Split-Path $PSScriptRoot -Parent) 'modules/pim/pim.bicep'),
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

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw 'Azure CLI (az) is not installed or is not on PATH.'
}
if (-not (Test-Path -LiteralPath $InputFile)) { throw "Input JSON not found: $InputFile" }
if (-not (Test-Path -LiteralPath $PolicyParameterFile)) { throw "Policy parameter file not found: $PolicyParameterFile" }
if (-not (Test-Path -LiteralPath $TemplateFile)) { throw "Bicep template not found: $TemplateFile" }

try { $request = Get-Content -LiteralPath $InputFile -Raw | ConvertFrom-Json }
catch { throw "Unable to parse input JSON '$InputFile': $($_.Exception.Message)" }

$principalId = [string]$request.pimAccessRequest.requestor.entraObjectId
$access = $request.pimAccessRequest.requestedAccess
$scope = $access.scope
$subscriptionId = [string]$scope.subscriptionId
$roleGuid = [string]$access.roleDefinitionId
$requestType = [string]$access.requestType
$duration = [string]$access.duration
$justification = [string]$access.justification

Assert-NotPlaceholder $principalId 'pimAccessRequest.requestor.entraObjectId'
Assert-NotPlaceholder $subscriptionId 'pimAccessRequest.requestedAccess.scope.subscriptionId'
Assert-NotPlaceholder $roleGuid 'pimAccessRequest.requestedAccess.roleDefinitionId'
Assert-NotPlaceholder $justification 'pimAccessRequest.requestedAccess.justification'

if ($scope.type -ne 'Subscription') {
    throw "This runner currently supports Subscription scope only. input.json scope.type='$($scope.type)'."
}
if ($requestType -notin @('AdminAssign','AdminUpdate','AdminRemove','AdminExtend','AdminRenew')) {
    throw "Unsupported requestType '$requestType'."
}
$allowedDurations = @('PT1H','PT2H','PT3H','PT4H','PT5H','PT6H','PT8H','PT12H','PT24H','P1D','P2D','P3D','P5D','P7D','P10D','P14D','P15D','P21D','P30D','P45D','P60D','P90D','P120D','P180D','P270D','P365D','P1W','P2W','P3W','P4W','P1M','P2M','P3M','P4M','P6M','P9M','P12M','P1Y','P2Y')
if ($duration -notin $allowedDurations) { throw "Unsupported duration '$duration'." }
if ($roleGuid -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$') {
    throw "roleDefinitionId must be a role definition GUID, not a full resource ID. Got '$roleGuid'."
}

$roleDefinitionResourceId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/roleDefinitions/$roleGuid"
$deploymentName = "bifrostPimEligibility$(Get-Date -Format 'yyyyMMddHHmmss')"
$requestName = [guid]::NewGuid().ToString()
$startDateTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$metadata = $request.pimAccessRequest.requestMetadata
Write-Host "Requestor: $($request.pimAccessRequest.requestor.userPrincipalName)"
Write-Host "Subscription: $subscriptionId"
Write-Host "Role: $($access.roleName) ($roleGuid)"
Write-Host "Ticket: $($metadata.ticketSystem) / $($metadata.ticketNumber) / $($metadata.ticketId)"
Write-Host "Request: $requestType | Duration: $duration"

# Azure CLI parameter-file deployment expects one .bicepparam file. Build a temporary
# parameter file beside the policy file so its relative 'using' path remains valid.
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
"@

try {
    Set-Content -LiteralPath $tempParamFile -Value ($policyText.TrimEnd() + $requestParams) -Encoding utf8

    if ($WhatIf) {
        Write-Host 'WhatIf mode: temporary parameters generated; no deployment submitted.' -ForegroundColor Yellow
        Write-Host "Generated parameter file: $tempParamFile"
        return
    }

    Invoke-AzChecked @('account','set','--subscription',$subscriptionId) 'Set Azure subscription'
    $account = (& az account show --output json | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to read current Azure account.' }
    if ($account.id -ne $subscriptionId) { throw "Azure CLI subscription mismatch. Expected '$subscriptionId', got '$($account.id)'." }

    Invoke-AzChecked @('deployment','sub','validate','--name',$deploymentName,'--location','eastus','--parameters',$tempParamFile) 'Validate subscription deployment'
    Invoke-AzChecked @('deployment','sub','create','--name',$deploymentName,'--location','eastus','--parameters',$tempParamFile,'--output','json') 'Submit PIM eligibility request'
    Write-Host 'PIM eligibility request deployment completed. Check deployment outputs/status in Azure.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $tempParamFile) { Remove-Item -LiteralPath $tempParamFile -Force }
}
