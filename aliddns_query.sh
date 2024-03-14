#!/bin/sh

# Set Access Key ID Access Key Secret
accessKeyId="yourAccessKeyId"
accessKeySecret="yourAccessKeySecret"
subDomain="yourDomain" # e.g.: a.example.com

# Set request param
method="GET"
host="alidns.aliyuncs.com"
action="DescribeSubDomainRecords"
version="2015-01-09"
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
nonce=$(date +%s)

# Construct the StringToSign
canonicalQueryString="Format=JSON&SubDomain=$subDomain"
canonicalHeaders="host:$host\nx-acs-action:$action\nx-acs-date:$date\nx-acs-signature-nonce:$nonce\nx-acs-version:$version\n"
signedHeaders="host;x-acs-action;x-acs-date;x-acs-signature-nonce;x-acs-version"
hashRequestPayload=$(echo -n "$requestPayload" | openssl dgst -sha256 -hex | sed 's/^.* //')
canonicalRequest="$method\n/\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$hashRequestPayload"
ct=$(echo -e "$canonicalRequest")
hashedCanonicalRequest=$(echo -n "$ct" | openssl dgst -sha256 -hex | sed 's/^.* //')

# Signature
stringToSign="ACS3-HMAC-SHA256\n$hashedCanonicalRequest"
st=$(echo -e $stringToSign)
signature=$(echo -n "$st" | openssl dgst -sha256 -hmac "$accessKeySecret" -hex | sed 's/^.* //')

# Construct the Authorization
authorizationHeader="ACS3-HMAC-SHA256 Credential=$accessKeyId,SignedHeaders=$signedHeaders,Signature=$signature"

# Call OpenAPI
update_result=$(curl -X $method -s "https://$host/?$canonicalQueryString" \
  -H "Authorization: $authorizationHeader" \
  -H "x-acs-action: $action" \
  -H "x-acs-date: $date" \
  -H "x-acs-signature-nonce: $nonce" \
  -H "x-acs-version: $version")

echo "response: $update_result"
