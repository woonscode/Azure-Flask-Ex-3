param location string = resourceGroup().location
param containerRegistryName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string

// param adminCredentialsKeyVaultResourceId (string)

module containerRegistry 'modules/container-registry/registry/main.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  } 
}

// resource keyvault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
//   name: keyVaultName
// }

// module website 'modules/web/site/main.bicep' = {
//   dependsOn: [
//    appServicePlan
//    containerRegistry
//    keyvault
//   ]
//   name: '${uniqueString(deployment().name)}-site'
//   params: {
//    name: siteName
//    location: location
//    kind: 'app'
//    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
//    siteConfig: {
//     linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
//     appCommandLine: ''
//    }
//    appSettingsKeyValuePairs: {
//     WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
//    }
//    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
//    dockerRegistryServerUserName: keyvault.getSecret(keyVaultSecretNameACRUsername)
//    dockerRegistryServerPassword: keyvault.getSecret(keyVaultSecretNameACRPassword1)
//   }
// }
  
module appServicePlan 'modules/web/serverfarm/main.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    // kind: 'Linux'
    reserved: true
  }
}

module webApp 'modules/web/site/main.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: ['the url of your azure docker container registry']
      DOCKER_REGISTRY_SERVER_USERNAME: ['the user name of your docker container registry']
      DOCKER_REGISTRY_SERVER_PASSWORD: ['the user password of your docker container registry']
    }
  }
  dependsOn: [
    containerRegistry
  ]
}
