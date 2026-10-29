using '../modules/main.bicep'
param environment = 'dev'

param location = 'eastus'

param vmAdminPassword = ''



param landingZones =  {
  resourceGroups: [
    {
      rgName: 'rg-dev-n'
      location: location
      tags: {
        Environment: environment
        CostCenter: 'CC1001'
        Application: 'LandingZone'
        Team: 'CloudOps'
      }
    }
  ]
  vnets: [
    {
      vnetName: 'hubvnet'
      location: location
      resourceGroupName: 'rg-dev-n'
      addressPrefixes: ['10.0.0.0/16']
      tags: {
        Environment: environment
        CostCenter: 'CC1001'
        Application: 'LandingZone'
        Team: 'CloudOps'
      }
      subnets: [
        {
          name: 'appsubnet'
          // addressPrefix: '10.0.0.0/28'
          addressPrefix: '10.0.1.0/24'
          // nsgName: 'testNSG'
          // routeTableName: 'rt-spoke'
         }

  ]
}

]
  vms: [
      {
      vmName: '${environment}-vm1'
      location: location
      resourceGroupName: 'rg-dev-n'
      vnetName: 'hubvnet'
      subnetName: 'appsubnet'
      adminUsername: 'azureuser'
      keyVaultName: 'kv-test-dev-eastus120901'
      vmsize: 'Standard_D2s_v3'
     // asgName: 'asg-dev-eastus'
      tags: {
        Environment: environment
        CostCenter: 'CC1001'
        Application: 'LandingZone'
        Team: 'CloudOps'
      }

     }
  ]
  asgs: [

  ]
  nsg:[
   
  ]

  routeTables: [
   
  ]
  storageAccounts: [

  ]
  keyVaults: [

]

 peerings: [

]


  backupVaults: [

  ]

  backupPolicies: [

  ]

  vmBackups: [

  ]

  vnetGateways: [

  ]
  actionGroups: [

]

alerts: [

]
}