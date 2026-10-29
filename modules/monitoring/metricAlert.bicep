@description('Alert Name')
param alertName string

@description('Target Resource Name')
param targetResourceName string

@description('Action Group Name')
param actionGroupName string

@description('Metric Namespace')
param metricNamespace string

@description('Metric Name')
param metricName string

@description('Operator')
param operator string

@description('Threshold')
param threshold int

@description('Severity')
param severity int = 2

@description('Alert Description')
param alertDescription string

@description('Evaluation Frequency')
param evaluationFrequency string = 'PT5M'

@description('Window Size')
param windowSize string = 'PT5M'

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' existing = {
  name: targetResourceName
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' existing = {
  name: actionGroupName
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'

  properties: {
    description: alertDescription

    severity: severity

    enabled: true

    scopes: [
      vm.id
    ]

    evaluationFrequency: evaluationFrequency
    windowSize: windowSize

    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'

      allOf: [
        {
          name: metricName

          criterionType: 'StaticThresholdCriterion'

          metricNamespace: metricNamespace

          metricName: metricName

          operator: operator

          threshold: threshold

          timeAggregation: 'Average'
        }
      ]
    }

    autoMitigate: true

    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

output alertId string = metricAlert.id
