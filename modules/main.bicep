targetScope = 'subscription'

@description('Complete deployment configuration loaded from root input.json by GitHub Actions.')
param config object

@description('Explicit opt-in for PIM eligibility. Disabled by default in workflow_dispatch.')
param deployPim bool = false

var rg = config.resourceGroup
var vmConfig = config.virtualMachine
var vmNetwork = vmConfig.network
var location = config.deployment.location
var tags = union(rg.tags, vmConfig.tags)

module resourceGroupModule 'resource-group/resource-group.bicep' = {
  name: 'bifrost-rg-${uniqueString(rg.name)}'
  params: { name: rg.name, location: rg.location, tags: rg.tags }
}

module nsgModule 'networking/nsg.bicep' = {
  name: 'bifrost-nsg-${uniqueString(rg.name, vmNetwork.networkSecurityGroupName)}'
  scope: resourceGroup(rg.name)
  dependsOn: [ resourceGroupModule ]
  params: {
    location: location
    nsgName: vmNetwork.networkSecurityGroupName
    securityRules: [{ name: 'AllowSSHFromApprovedSource', priority: 100, direction: 'Inbound', access: 'Allow', protocol: 'Tcp', sourcePortRange: '*', destinationPortRange: '22', sourceAddressPrefix: vmNetwork.sshAllowedSourceAddressPrefix, destinationAddressPrefix: '*' }]
    tags: tags
  }
}

module vnetModule 'networking/vnet.bicep' = {
  name: 'bifrost-vnet-${uniqueString(rg.name, vmNetwork.virtualNetworkName)}'
  scope: resourceGroup(rg.name)
  dependsOn: [ nsgModule ]
  params: {
    location: location
    vnetName: vmNetwork.virtualNetworkName
    addressPrefixes: [vmNetwork.addressPrefix]
    subnets: [{ name: vmNetwork.subnetName, addressPrefix: vmNetwork.subnetPrefix, nsgName: vmNetwork.networkSecurityGroupName }]
    tags: tags
  }
}

module vmModule 'compute/vm-linux.bicep' = {
  name: 'bifrost-vm-${uniqueString(rg.name, vmConfig.name)}'
  scope: resourceGroup(rg.name)
  dependsOn: [ vnetModule, nsgModule ]
  params: {
    location: vmConfig.location
    vmName: vmConfig.name
    adminUsername: vmConfig.adminUsername
    vmSize: vmConfig.vmSize
    sshPublicKey: vmConfig.sshPublicKey
    image: vmConfig.image
    osDisk: vmConfig.osDisk
    subnetName: vmNetwork.subnetName
    vnetName: vmNetwork.virtualNetworkName
    networkInterfaceName: vmNetwork.networkInterfaceName
    createPublicIp: vmNetwork.publicIp.create
    publicIpName: vmNetwork.publicIp.name
    publicIpAllocationMethod: vmNetwork.publicIp.allocationMethod
    publicIpSku: vmNetwork.publicIp.sku
    tags: tags
  }
}

module pimModule 'pim/pim.bicep' = if (deployPim && config.pim.enabled) {
  name: 'bifrost-pim-${uniqueString(rg.name, config.pim.principal.principalId, config.pim.role.roleDefinitionId)}'
  scope: resourceGroup(rg.name)
  dependsOn: [ resourceGroupModule ]
  params: {
    principalId: config.pim.principal.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', last(split(config.pim.role.roleDefinitionId, '/')))
    justification: config.pim.justification
    ticketNumber: config.pim.ticketInfo.ticketNumber
    ticketSystem: config.pim.ticketInfo.ticketSystem
    duration: config.pim.schedule.duration
    requestName: guid(resourceGroupModule.outputs.resourceGroupId, config.pim.principal.principalId, config.pim.role.roleDefinitionId, 'bifrost-pim-eligibility')
  }
}

output resourceGroupName string = resourceGroupModule.outputs.resourceGroupName
output virtualMachineName string = vmModule.outputs.vmNameOut
output virtualMachineId string = vmModule.outputs.vmId
output networkInterfaceId string = vmModule.outputs.networkInterfaceId
output publicIpAddressId string = vmModule.outputs.publicIpId