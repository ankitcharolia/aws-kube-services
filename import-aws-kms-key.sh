#!/bin/bash

# Reference: https://docs.aws.amazon.com/kms/latest/developerguide/importing-keys-create-cmk.html


aws kms get-parameters-for-import \
    --key-id 1234abcd-12ab-34cd-56ef-1234567890ab \
    --wrapping-algorithm RSAES_OAEP_SHA_1 \
    --wrapping-key-spec RSA_2048

openssl enc -d -base64 -A -in PublicKey.b64 -out PublicKey.bin
openssl enc -d -base64 -A -in ImportToken.b64 -out ImportToken.bin

openssl rand -out PlaintextKeyMaterial.bin 32

openssl pkeyutl \
    -in PlaintextKeyMaterial.bin \
    -out EncryptedKeyMaterial.bin \
    -inkey PublicKey.bin \
    -keyform DER -pubin \
    -encrypt \
    -pkeyopt rsa_padding_mode:oaep \
    -pkeyopt rsa_oaep_md:sha1        

aws kms import-key-material --key-id 1234abcd-12ab-34cd-56ef-1234567890ab \ 
    --encrypted-key-material fileb://EncryptedKeyMaterial.bin \
    --import-token fileb://ImportToken.bin \
    --expiration-model KEY_MATERIAL_DOES_NOT_EXPIRE