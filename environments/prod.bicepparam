using '../modules/main.bicep'
param environment = 'dev'

param location = 'eastus'

param vmAdminPassword = ''



param landingZones =  {
  resourceGroups: [
    {
      rgName: 'rg-infra'
      location: location
      tags: {

      }
    }
  ]
  vnets: [


]
  vms: [

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