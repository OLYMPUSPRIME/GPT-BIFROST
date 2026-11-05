[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory)]
    [string]$InputJsonPath,

    [Parameter(Mandatory)]
    [string]$DeploymentLocation,

    [switch]$Execute
)

$ErrorActionPreference = 'Stop'

# BIFROST Mark-2 currently supports Azure Resource PIM eligibility only
# through this Bicep runner. Entra directory-role and PIM Group requests
# require separate Microsoft Graph implementations.

if (-not (Test-Path -LiteralPath $InputJsonPath -PathType Leaf)) {
    throw "Input JSON not found: $InputJsonPath"
}

$request = Get-Content -LiteralPath $InputJsonPath -Raw | ConvertFrom-Json

$required = @(
    $request.request.ticketNumber,
    $request.request.ticketSystem,
    $request.request.requestedBy,
    $request.request.justification,
    $request.subscription.subscriptionId,
    $request.pimRequest.principal.objectId,
    $request.pimRequest.role.roleDefinitionId,
    $request.pimRequest.assignment.type
)
if ($required | Where-Object { [string]::IsNullOrWhiteSpace([string]$_) }) {
    throw 'One or more required request values are missing.'
}

if ($request.request.approved -ne $true) {
    throw "Ticket $($request.request.ticketNumber) is not approved. Refusing to proceed."
}

if ($request.pimRequest.platform -ne 'AzureResource') {
    throw "Platform '$($request.pimRequest.platform)' is not supported by this Bicep runner. Entra/PIM Group require Graph-based automation."
}

if ($request.pimRequest.assignment.type -ne 'Eligible') {
    throw 'This runner only creates Eligible assignments. Active assignment automation is not enabled.'
}

if ($request.pimRequest.scope.type -ne 'Subscription') {
    throw 'The current pim.bicep is subscription-targeted. RG/resource scopes require the separately validated REST API runner.'
}

$subscriptionId = [string]$request.subscription.subscriptionId
$principalId = [string]$request.pimRequest.principal.objectId
$roleGuid = [string]$request.pimRequest.role.roleDefinitionId
if ($roleGuid -notmatch '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') {
    throw 'role.roleDefinitionId must be a role GUID for this subscription-scoped module.'
}

$roleDefinitionId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/roleDefinitions/$roleGuid"
$duration = [string]$request.pimRequest.assignment.expiration.duration
if ($request.pimRequest.assignment.expiration.type -ne 'AfterDuration' -or $duration -notmatch '^P(?!$)(\\d+Y)?(\\d+M)?(\\d+W)?(\\d+D)?(T(\\d+H)?(\\d+M)?(\\d+S)?)?$') {
    throw 'This runner currently supports ISO 8601 AfterDuration only (for example P30D).'
}

$startDateTime = [string]$request.pimRequest.assignment.startDateTime
if ([string]::IsNullOrWhiteSpace($startDateTime)) {
    $startDateTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

$requestName = [guid]::NewGuid().ToString()
$justification = "Ticket $($request.request.ticketNumber): $($request.request.justification)"

$parameters = @(
    "principalId=$principalId",
    "roleDefinitionId=$roleDefinitionId",
    "requestType=AdminAssign",
    "justification=$justification",
    "duration=$duration",
    "startDateTime=$startDateTime",
    "requestName=$requestName",
    "ticketNumber=$($request.request.ticketNumber)",
    "ticketSystem=Jira"
)

$command = @(
    'az', 'deployment', 'sub', 'create',
    '--subscription', $subscriptionId,
    '--location', $DeploymentLocation,
    '--template-file', 'modules/pim/pim.bicep',
    '--parameters'
) + $parameters

Write-Host "Validated Jira ticket: $($request.request.ticketNumber)"
Write-Host "Target subscription: $subscriptionId"
Write-Host "Principal object ID: $principalId"
Write-Host "Role: $($request.pimRequest.role.name)"
Write-Host "Assignment: Eligible for $duration"
Write-Host "Request GUID: $requestName"

if (-not $Execute) {
    Write-Host 'DRY RUN: no Azure deployment was submitted. Use -Execute after reviewing the values.'
    Write-Host ('Command preview: ' + ($command -join ' '))
    return
}

if ($PSCmdlet.ShouldProcess($subscriptionId, "Create PIM eligibility for ticket $($request.request.ticketNumber)")) {
    & az @command
    if ($LASTEXITCODE -ne 0) {
        throw "Azure deployment failed with exit code $LASTEXITCODE"
    }
}
