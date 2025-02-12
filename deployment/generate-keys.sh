#!/usr/bin/env bash

# Copyright (c) 2019 StackRox Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# generate-keys.sh
#
# Generate a (self-signed) CA certificate and a certificate and private key to be used by the webhook demo server.
# The certificate will be issued for the Common Name (CN) of `webhook-server.webhook-demo.svc`, which is the
# cluster-internal DNS name for the service.
#
# NOTE: THIS SCRIPT EXISTS FOR DEMO PURPOSES ONLY. DO NOT USE IT FOR YOUR PRODUCTION WORKLOADS.

: ${1?'missing key directory'}

key_dir="$1"

chmod 0700 "$key_dir"
cd "$key_dir"

# # Works with Kubernetes 1.18
# # Generate the CA cert and private key
# openssl req -nodes -new -x509 -keyout ca.key -out ca.crt -subj "/CN=Admission Controller Webhook Demo CA"
# # Generate the private key for the webhook server
# openssl genrsa -out webhook-server-tls.key 2048
# # Generate a Certificate Signing Request (CSR) for the private key, and sign it with the private key of the CA.
# openssl req -new -key webhook-server-tls.key -subj "/CN=webhook-server.webhook-demo.svc" \
#     | openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -out webhook-server-tls.crt

# Updates the code to work with Kubernetes > 1.18
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
openssl genrsa -out warden.key 2048
openssl req -new -key warden.key -out warden.csr -subj "/CN=webhook-server.webhook-demo.svc" -config ../server.conf
openssl x509 -req -in warden.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out warden.crt -days 100000 -extensions v3_req -extfile ../server.conf

cp warden.crt webhook-server-tls.crt
cp warden.key webhook-server-tls.key
