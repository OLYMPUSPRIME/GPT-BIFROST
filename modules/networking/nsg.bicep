param location string
param nsgName string
param securityRules array = []

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties:{
  securityRules: [
     for rule in securityRules: {
       name: rule.name
       properties: {
         priority: rule.priority
         direction: rule.direction
         access: rule.access
         protocol: rule.protocol
         sourcePortRange: rule.sourcePortRange
         destinationPortRange: rule.destinationPortRange
         sourceAddressPrefix: rule.sourceAddressPrefix
         destinationAddressPrefix: rule.destinationAddressPrefix
       }
     }
   ]
}

}

output nsgId string = nsg.id
output nsgName string = nsg.name
