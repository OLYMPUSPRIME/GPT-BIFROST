using '../modules/main.bicep'
param environment = 'dev'

param location = 'eastus'

param vmAdminPassword = ''


param landingZones =  {
  resourceGroups: [
    {
      rgName: 'rg-test'
      location: location
      tags: {

      }
    }
    {
      rgName: 'rg-test-dev'
      location: location
      tags: {

      }
    }
  ]
  vnets: [
    // {
    //   vnetName: 'hubvnet'
    //   location: location
    //   resourceGroupName: 'rg-dev-n'
    //   addressPrefixes: ['10.0.0.0/16']
    //   tags: {
    //     Environment: environment
    //     CostCenter: 'CC1001'
    //     Application: 'LandingZone'
    //     Team: 'CloudOps'
    //   }
//       subnets: [
//         {
//           name: 'appsubnet'
//           addressPrefix: '10.0.0.0/28'
//           addressPrefix: '10.0.1.0/24'
//           nsgName: 'testNSG'
//           routeTableName: 'rt-spoke'
//          }
//         {
//           name: 'GatewaySubnet'
//           addressPrefix: '10.0.255.0/27'
//         }  
//   ]
// }
// {
//   vnetName: 'spokevnet'
//   location: location
//   resourceGroupName: 'rg-dev-n'
//   addressPrefixes: ['10.1.1.0/24']
//   tags: {
//     Environment: environment
//     CostCenter: 'CC1001'
//     Application: 'LandingZone'
//     Team: 'CloudOps'
//     }
//   subnets: [
//     {
//       name: 'appsubnetspoke'
//       addressPrefix: '10.1.1.0/24'
//       nsgName: 'testNSG'
//       routeTableName: 'rt-spoke'
//     }
    // {
    //   name: 'websubnet'
    //   addressPrefix: '10.0.1.0/28'
    //   nsgName: 'testNSG'
    //   routeTableName: 'rt-spoke'
    // }

//]
//} 
]
  vms: [
      //{
     //  vmName: '${environment}-vm1'
     //  location: location
     //  resourceGroupName: 'rg-dev-n'
     //  vnetName: 'hubvnet'
     //  subnetName: 'appsubnet'
     //  adminUsername: 'azureuser'
     //  keyVaultName: 'kv-test-dev-eastus120901'
     //  vmsize: 'Standard_D2s_v3'
     // asgName: 'asg-dev-eastus'
     //  tags: {
     //    Environment: environment
     //    CostCenter: 'CC1001'
     //    Application: 'LandingZone'
     //    Team: 'CloudOps'
     //  }

     // }
    // {
    //   vmName: '${environment}-vm2'
    //   location: location
    //   resourceGroupName: 'rg-dev-n'
    //   vnetName: 'spokevnet'
    //   subnetName: 'appsubnet'
    //   adminUsername: adminUsername
    //   adminPassword : '****'
    //   vmsize: 'Standard_D2s_v3'
    //   // asgName: 'asg-dev-eastus'
    // }
  ]
  asgs: [
    // {
    //   asgName: 'asg-dev-eastus'
    //   location: location
    //   resourceGroupName: 'rg-dev-n'
    // }
  ]
  nsg:[
  //   {
  //   location: location
  //   nsgName: 'testNSG'
  //   resourceGroupName: 'rg-dev-n'
    
  //   securityRules: [
  //    {
  //      name: 'Allow-RDP'
  //      priority: 100
  //      direction: 'Inbound'
  //      access: 'Allow'
  //      protocol: 'Tcp'
  //      sourcePortRange: '*'
  //      destinationPortRange: '3389'
  //      sourceAddressPrefix: '*'
  //      destinationAddressPrefix: '*'
  //     }
  //   ]
  // }
  ]

  routeTables: [
    // {
    //   routeTableName: 'rt-spoke'

    //   location: location

    //   resourceGroupName: 'rg-dev-n'

    //   disableBgpRoutePropagation: false

    //   routes: [
    //     {
    //       name: 'default-route'

    //       properties: {
    //         addressPrefix: '0.0.0.0/0'

    //         nextHopType: 'Internet'
    //       }
    //     }
    //   ]
    // }
  ]
  storageAccounts: [
  //   {
  //     storageAccountName: 'stdev09095'
  //     resourceGroupName: 'rg-dev-n'
  //     location: location

  //     tags: {
  //       Environment: 'Dev'
  //     }
  //   }
  ]
  keyVaults: [
  // {
  //   keyVaultName: 'kv-test-dev-eastus120901'

  //   resourceGroupName: 'rg-dev-n'

  //   location: location

  // }
]

 peerings: [
 // {
 //    peeringName: 'hub-to-spoke'

 //    sourceVnetName: 'hubvnet'
 //    sourceVnetResourceGroupName: 'rg-dev-n'

 //    remoteVnetName: 'spokevnet'
 //    remoteVnetResourceGroupName: 'rg-dev-n'
 //  }

 //  {
 //    peeringName: 'spoke-to-hub'

 //    sourceVnetName: 'spokevnet'
 //    sourceVnetResourceGroupName: 'rg-dev-n'

 //    remoteVnetName: 'hubvnet'
 //    remoteVnetResourceGroupName: 'rg-dev-n'
 //  }
]




  backupVaults: [
//     {
//       vaultName: 'rsv-test-dev'
//       resourceGroupName: 'rg-dev-n'
//       location: 'eastus'
//       sku: 'Standard'
//     }
  ]

  backupPolicies: [
//     {
//       policyName: 'DailyBackup'
//       resourceGroupName: 'rg-dev-n'

//       vaultName: 'rsv-test-dev'

//       backupTime: '2025-01-01T02:00:00Z'
//     }
  ]

  vmBackups: [
//     {
//       vmName: 'dev-vm1'

//       resourceGroupName: 'rg-dev-n'

//       vaultName: 'rsv-test-dev'

//       policyName: 'DailyBackup'
//     }
  ]

  vnetGateways: [
    // {
    //   gatewayName: 'hub-vpngw'

    //   resourceGroupName: 'rg-dev-n'

    //   location: location

    //   vnetName: 'hubvnet'
    //   gatewaySubnetName: 'GatewaySubnet'

    //   gatewaySku: 'VpnGw1AZ'
    // }
  ]
  actionGroups: [
  // {
  //   actionGroupName: 'ag-ops'

  //   resourceGroupName: 'rg-dev-n'


  //   emailReceivers: [
  //     {
  //       name: 'OperationsTeam'
  //       emailAddress: 'ops@contoso.com'
  //     }
  //     {
  //       name: 'CloudTeam'
  //       emailAddress: 'cloud@contoso.com'
  //     }
  //   ]
  // }
]

alerts: [
//   {
//     alertName: 'HighCPUAlert'

//     resourceGroupName: 'rg-dev-n'

//     targetResourceName: 'dev-vm1'

//     actionGroupName: 'ag-ops'

//     metricNamespace: 'Microsoft.Compute/virtualMachines'

//     metricName: 'Percentage CPU'

//     operator: 'GreaterThan'

//     threshold: 80

//     severity: 2

//     alertDescription: 'CPU utilization greater than 80%'
//   }

//   {
//     alertName: 'HighMemoryAlert'

//     resourceGroupName: 'rg-dev-n'

//     targetResourceName: 'dev-vm1'

//     actionGroupName: 'ag-ops'

//     metricNamespace: 'Microsoft.Compute/virtualMachines'

//     metricName: 'Available Memory Bytes'

//     operator: 'LessThan'

//     threshold: 1000000000

//     severity: 2

//     alertDescription: 'Available memory is low'
//   }
]


}