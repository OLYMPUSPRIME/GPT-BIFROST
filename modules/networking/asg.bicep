@description('Name of the Application Security Group (ASG) to create.')
param asgName string

@description('Azure region where the Application Security Group will be deployed.')
param location string

resource asg 'Microsoft.Network/applicationSecurityGroups@2023-04-01' = {
  name: asgName
  location: location
}

output asgId string = asg.id
output asgName string = asg.name
