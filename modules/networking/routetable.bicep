@description('Route Table Name')
param routeTableName string

@description('Location')
param location string = resourceGroup().location

@description('Disable BGP Route Propagation')
param disableBgpRoutePropagation bool = false

@description('Routes')
param routes array = []

resource routeTable 'Microsoft.Network/routeTables@2022-07-01' = {
  name: routeTableName
  location: location

  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routes
  }
}

output routeTableId string = routeTable.id
output routeTableName string = routeTable.name
