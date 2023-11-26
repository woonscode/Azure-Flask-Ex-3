param location string = resourceGroup().location
param keyVaultName string

module keyVault 'modules/key-vault/vault/main.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
