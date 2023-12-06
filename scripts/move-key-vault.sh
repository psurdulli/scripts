#!/bin/sh

SOURCE_KV_NAME="SourceKeyVault"
DEST_KEY_VAULT="newKeyVault"

SECRETS+=($(az keyvault secret list --vault-name $SOURCE_KV_NAME --query "[].id" -o tsv))

for SECRET in "${SECRETS[@]}"; do
SECRETNAME=$(echo "$SECRET" | sed 's|.*/||')
SECRET_CHECK=$(az keyvault secret list --vault-name $DEST_KEY_VAULT --query "[?name=='$SECRETNAME']" -o tsv)
if [ -n "$SECRET_CHECK" ]
then
    echo "$SECRETNAME already exists in $DEST_KEY_VAULT"
else
     echo "Copying $SECRETNAME from Source KeyVault: $SOURCE_KV_NAME to Destination KeyVault: $DEST_KEY_VAULT"
    SECRET=$(az keyvault secret show --vault-name $SOURCE_KV_NAME -n $SECRETNAME --query "value" -o tsv)
    az keyvault secret set --vault-name $DEST_KEY_VAULT -n $SECRETNAME --value "$SECRET" >/dev/null
fi
done