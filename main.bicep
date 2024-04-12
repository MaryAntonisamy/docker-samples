resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: 'my-container-group'
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'my-app-container'
        properties: {
          image: 'myregistry.azurecr.io/myapp:latest'
          resources: {
            requests: {
              cpu: 1
              memoryInGb: 1.5
            }
          }
          ports: [
            {
              port: 80
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
    }
  }
}
