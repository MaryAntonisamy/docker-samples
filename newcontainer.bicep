param location string = 'EastUS'
param appName string = 'my-background-service'
param acrName string = 'myContainerRegistry'
param imageTag string = 'latest'
param acrLoginServer string // e.g., 'mycontainerregistry.azurecr.io'

// Create a Log Analytics workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: '${appName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Create a Container Apps Environment
resource containerAppEnv 'Microsoft.App/containerAppsEnvironments@2022-03-01' = {
  name: '${appName}-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.properties.primarySharedKey
      }
    }
  }
}

// Create the Container App
resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      secrets: [
        {
          name: 'acrPassword'
          value: '<Your-ACR-Password>'
        }
      ]
      registries: [
        {
          server: acrLoginServer
          username: acrName
          passwordSecretRef: 'acrPassword'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: '${acrLoginServer}/${appName}:${imageTag}'
          env: []
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'httpscalingrule'
            custom: {
              type: 'http'
              metadata: {
                concurrentRequests: '50'
              }
            }
          }
        ]
      }
    }
  }
}