#!/bin/bash

if [[ -z $1 ]]
then
  echo "no api endpoint supplied as script parameter. defaulting to hardcoded version"
  API_ENDPOINT="https://dvtkxey9mk.execute-api.eu-central-1.amazonaws.com/api/fiscalismia/post/sheet_url/process_lambda/return_tsv_file_urls"
else
  API_ENDPOINT=$1
fi

curl "$API_ENDPOINT" \
  -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' \
  -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: cross-site' -H 'DNT: 1' -H 'Sec-GPC: 1' \
  -H 'TE: trailers' -H 'Priority: u=0, i' -H 'Authorization: MY_ENV_VAR_API_KEY' -H 'Origin: null' -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  --data-raw 'herp derp url google sheets'