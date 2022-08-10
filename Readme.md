# Docker file and server to scan the web

### Command to build docker container
```
$ sudo podman build --cap-add ALL .
```

### Command to start server to start and enumerate containers
```
$ npm i
$ node .
```

### Running in Azure
You will need to set up a `Template spec` with the following...
You will need to change `--YOUR SSH KEY--` to your PCs ssh key.

```json
{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"location": {
			"defaultValue": "[resourceGroup().location]",
			"type": "String",
			"metadata": {
				"description": "Location for all resources."
			}
		}
	},
	"variables": {
		"virtualNetworkName": "[concat(parameters('location'),'-vnet-vmaccess')]",
		"networkSecurityGroupsName": "[concat(parameters('location'),'-vnet-vsg')]",
		"nicName": "[concat(parameters('location'),'vmka5')]",
		"nicNameStr": "[concat(parameters('location'),'strka5')]",
		"nicNameNet": "[concat(parameters('location'),'netka5')]",
		"publicIPAddressName": "[concat(parameters('location'),'-ipka5')]",
		"vnetAddressPrefix": "10.0.0.0/16",
		"subnetName": "VMAccess",
		"subnetPrefix": "10.0.0.0/24",
		"subnetRef": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('virtualNetworkName'), variables('subnetName'))]"
	},
	"resources": [
		{
			"type": "Microsoft.Network/networkSecurityGroups",
			"apiVersion": "2020-11-01",
			"name": "[variables('networkSecurityGroupsName')]",
			"location": "[parameters('location')]",
			"properties": {
				"securityRules": [
					{
						"name": "SSH",
						"properties": {
							"protocol": "TCP",
							"sourcePortRange": "*",
							"destinationPortRange": "22",
							"sourceAddressPrefix": "*",
							"destinationAddressPrefix": "*",
							"access": "Allow",
							"priority": 300,
							"direction": "Inbound",
							"sourcePortRanges": [],
							"destinationPortRanges": [],
							"sourceAddressPrefixes": [],
							"destinationAddressPrefixes": []
						}
					}
				]
			}
		},
		{
			"type": "Microsoft.Storage/storageAccounts",
			"apiVersion": "2021-01-01",
			"name": "[variables('nicNameStr')]",
			"location": "[parameters('location')]",
			"sku": {
				"name": "Standard_LRS"
			}
		},
		{
			"type": "Microsoft.Network/publicIPAddresses",
			"apiVersion": "2020-06-01",
			"name": "[variables('publicIPAddressName')]",
			"location": "[parameters('location')]",
			"properties": {
				"publicIPAllocationMethod": "Dynamic",
				"dnsSettings": {
					"domainNameLabel": "[variables('publicIPAddressName')]"
				}
			}
		},
		{
			"type": "Microsoft.Network/virtualNetworks",
			"apiVersion": "2020-06-01",
			"name": "[variables('virtualNetworkName')]",
			"location": "[parameters('location')]",
			"properties": {
				"addressSpace": {
					"addressPrefixes": [
						"[variables('vnetAddressPrefix')]"
					]
				},
				"subnets": [
					{
						"name": "[variables('subnetName')]",
						"properties": {
							"addressPrefix": "[variables('subnetPrefix')]"
						}
					}
				]
			}
		},
		{
			"type": "Microsoft.Network/networkInterfaces",
			"apiVersion": "2020-06-01",
			"name": "[variables('nicNameNet')]",
			"location": "[parameters('location')]",
			"dependsOn": [
				"[resourceId('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
				"[resourceId('Microsoft.Network/virtualNetworks/', variables('virtualNetworkName'))]",
				"[resourceId('Microsoft.Network/networkSecurityGroups/', variables('networkSecurityGroupsName'))]"
			],
			"properties": {
				"ipConfigurations": [
					{
						"name": "ipconfig1",
						"properties": {
							"privateIPAllocationMethod": "Dynamic",
							"publicIPAddress": {
								"id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
							},
							"subnet": {
								"id": "[variables('subnetRef')]"
							}
						}
					}
				],
				"networkSecurityGroup": {
					"id": "[resourceId('Microsoft.Network/networkSecurityGroups',variables('networkSecurityGroupsName'))]"
				}
			}
		},
		{
			"type": "Microsoft.Compute/virtualMachines",
			"apiVersion": "2020-06-01",
			"name": "[variables('nicName')]",
			"location": "[parameters('location')]",
			"dependsOn": [
				"[resourceId('Microsoft.Storage/storageAccounts/', variables('nicNameStr'))]",
				"[resourceId('Microsoft.Network/networkInterfaces/', variables('nicNameNet'))]"
			],
			"properties": {
				"hardwareProfile": {
					"vmSize": "Standard_B1ls"
				},
				"osProfile": {
					"computerName": "[variables('nicName')]",
					"adminUsername": "userland",
					"linuxConfiguration": {
						"disablePasswordAuthentication": true,
						"ssh": {
							"publicKeys": [
								{
									"path": "/home/userland/.ssh/authorized_keys",
									"keyData": "--YOUR SSH KEY--"
								}
							]
						}
					}
				},
				"storageProfile": {
					"imageReference": {
						"publisher": "debian",
						"offer": "debian-11",
						"sku": "11",
						"version": "latest"
					},
					"osDisk": {
						"createOption": "FromImage"
					}
				},
				"networkProfile": {
					"networkInterfaces": [
						{
							"id": "[resourceId('Microsoft.Network/networkInterfaces',variables('nicNameNet'))]",
							"properties": {
								"deleteOption": "Delete"
							}
						}
					]
				},
				"diagnosticsProfile": {
					"bootDiagnostics": {
						"enabled": true,
						"storageUri": "[reference(variables('nicNameStr'),'2015-06-15').primaryEndpoints['blob']]"
					}
				}
			},
			"identity": {
				"type": "systemAssigned"
			}
		}
	]
}
```

##### To create VMs:
Replace REGION=... with your sorted available regions list
NOTE: You will have to change `index.js:const clients` to the number of regions you have
```sh
ID=$(az ts show --name --MY TEMPLATE NAME-- --resource-group --MY RESOURCE GROUP--  --version "--MY VERSION--" --query "id")
REGION="eastus eastus2 westus2 westus3"
for i in $REGION; do az deployment group create   --resource-group --MY RESOURCE GROUP--   --template-spec $ID --parameters "{ \"location\": {\"value\": \"$i\"}}" ; done
```

##### To start VMs:
You will need to create a storage account and create a share and copy the ssh-rsa key and username to .

```sh
echo '#!/bin/bash' > install.sh
echo 'echo "username=--STORE ACC NAME--" >> /etc/smb.cred' >> install.sh
echo 'echo "password=--STORE SSH-RSA KEY--" >> /etc/smb.cred' >> install.sh
curl https://raw.githubusercontent.com/Mr-Bossman/dist-masscan/master/install.sh >> install.sh
VMS=$(az vm list -d -g temp --query "[].name" -o tsv)
for i in $VMS; do az vm run-command invoke -g temp -n $i --command-id RunShellScript --scripts @install.sh; done
```

##### To list VMs IPs
```sh
az vm list -d -g temp --query "[].publicIps" -o tsv
```
