#!/bin/sh

# Set Access Key ID Access Key Secret
accessKeyId="yourAccessKeyId"
accessKeySecret="yourAccessKeySecret"
recordId="recordId"
rr="yourDomain" # e.g.: a.example.com -> a | abc.example.com -> abc
type="AAAA" # A or AAAA
requestPayload="" # Empty when using GET
interfaceName="" # # See `ifconfig -a`

# Set request param
method="GET"
host="alidns.aliyuncs.com"
action="UpdateDomainRecord"
version="2015-01-09"
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
nonce=$(date +%s)

if [ -z "$interfaceName" ]; then
  interface=""
else
  interface=" --interface $interfaceName "
fi

# Get the ip address
if [ "$type" = "AAAA" ]; then
  ipAddress=$(curl -s6 $interface 6.ipw.cn)
else
  ipAddress=$(curl -s $interface 4.ipw.cn)
fi

# Check the ip address
if [ -z "$ipAddress" ]; then
  echo "Failed to retrieve IPv4/IPv6 address. Exiting..."
  exit 1
fi

if [ "$type" = "AAAA" ]; then
  value=$(echo -e $ipAddress | sed 's/:/%3A/g')
else
  value=$ipAddress
fi

# Construct the StringToSign
canonicalQueryString="Format=JSON&RR=$rr&RecordId=$recordId&Type=$type&Value=$value"
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

if echo "$update_result" | grep -q '"Code"'; then
  echo "DDNS update failed."
  echo "CR: $ct"
  echo "hashedCR: $hashedCanonicalRequest"
  echo "response: $update_result"
  exit 1
else
  echo "DDNS update successful."
fi
