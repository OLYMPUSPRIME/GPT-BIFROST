@description('Action Group Name')
param actionGroupName string

@description('Email Receivers')
param emailReceivers array

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'global'

  properties: {
    groupShortName: take(actionGroupName, 12)

    enabled: true

    emailReceivers: [
      for receiver in emailReceivers: {
        name: receiver.name
        emailAddress: receiver.emailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

output actionGroupId string = actionGroup.id
output actionGroupNameOut string = actionGroup.name
