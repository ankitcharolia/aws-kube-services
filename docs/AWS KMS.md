# How to Encrypt and Decrypt the file with AWS KMS and store encrypted password files in Terraform repository

```shell
# List the available aliases
aws kms list-aliases
```

```shell
# decrypt the file, add password and encrypt it again.
aws kms decrypt --ciphertext-blob fileb://etc/secrets/stage.yaml.encrypted --output text --query Plaintext | base64 --decode > ./etc/secrets/stage.yaml
```

```shell
# encrypt the file
aws kms encrypt --key-id alias/secrets --plaintext fileb://etc/secrets/stage.yaml --output text --query CiphertextBlob | base64 --decode > ./etc/secrets/stage.yaml.encrypted
```