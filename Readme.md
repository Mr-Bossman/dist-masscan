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
You will need to create a storage account and create a share and copy the ssh-rsa key to `storageAccountKey`.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "location": {
            "type": "String"
        }
    },
    "resources": [
        {
            "type": "Microsoft.ContainerInstance/containerGroups",
            "apiVersion": "2021-10-01",
            "name": "[parameters('location')]",
            "location": "[parameters('location')]",
            "tags": {},
            "properties": {
                "containers": [
                    {
                        "name": "[parameters('location')]",
                        "properties": {
                            "image": "ja02/dist-masscan:latest",
                            "ports": [
                                {
                                    "protocol": "TCP",
                                    "port": 80
                                }
                            ],
                            "resources": {
                                "requests": {
                                    "memoryInGB": 1,
                                    "cpu": 1
                                }
                            },
                            "volumeMounts": [
                                {
                                    "mountPath": "/mnt",
                                    "name": "filesharevolume"
                                }
                            ]
                        }
                    }
                ],
                "restartPolicy": "Never",
                "osType": "Linux",
                "ipAddress": {
                    "ports": [
                        {
                            "protocol": "TCP",
                            "port": 80
                        }
                    ],
                    "type": "Public"
                },
                "volumes": [
                    {
                        "name": "filesharevolume",
                        "azureFile": {
                            "sharename": "--YOUR FILE SHARE NAME HERE--",
                            "storageAccountName": "--YOUR STORE ACC NAME HERE--",
                            "storageAccountKey": "--YOUR KEY HERE--"
                        }
                    }
                ]
            }
        }
    ]
}
```

##### To create vms:
Replace REGION=... with your sorted available regions list
NOTE: You will have to change `index.js:const clients` to the number of regions you have
```sh
ID=$(az ts show --name --MY TEMPLATE NAME-- --resource-group --MY RESOURCE GROUP--  --version "--MY VERSION--" --query "id")
REGION="eastus eastus2 westus2 westus3"
for i in $REGION; do az deployment group create   --resource-group --MY RESOURCE GROUP--   --template-spec $ID --parameters "{ \"location\": {\"value\": \"$i\"}}" ; done
```
