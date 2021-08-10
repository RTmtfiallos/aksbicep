// mandatory params
param dnsPrefix string = 'akscluster'
param linuxAdminUsername string
param sshRSAPublicKey string
param servicePrincipalClientId string
param acrprefix string  = 'acr'

param uniqueclustername string = '${dnsPrefix}${uniqueString(resourceGroup().id)}'
param acrname string = '${acrprefix}${uniqueString(resourceGroup().id)}'

@secure()
param servicePrincipalClientSecret string

// optional params
param clusterName string = uniqueclustername
param location string = resourceGroup().location

@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@minValue(1)
@maxValue(50)
param agentCount int = 3

param agentVMSize string = 'Standard_DS2_v2'
// osType was a defaultValue with only one allowedValue, which seems strange?, could be a good TTK test

resource aks 'Microsoft.ContainerService/managedClusters@2020-09-01' = {
  name: clusterName
  location: location
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
      secret: servicePrincipalClientSecret
    }
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: acrname
  location: resourceGroup().location
  sku: {
    name: 'Classic'
  }
  properties: {
    adminUserEnabled: true
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
