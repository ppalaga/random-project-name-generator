#!/bin/bash

tlds=( '.com' '.org' )
nameLength=6
minVowels=3

while true; do
  name=$(cat /dev/urandom | tr -dc 'a-z' | fold -w $nameLength | head -n 1)
  vowels=$(echo $name | sed 's/[^aeiou]//g')
  vowelsCnt="${#vowels}"
  if [ $vowelsCnt -ge $minVowels ]; then
    echo "$name :"
    tldCnt=0
    domains=""
    for tld in "${tlds[@]}"; do
      domain="$name$tld"
      if host $domain | grep "NXDOMAIN" >&/dev/null; then
        #if whois $domain | grep -E "(No match for|NOT FOUND)" >&/dev/null; then
            ((tldCnt++))
            domains="$domains $domain"
        #fi 
      fi
    done
    httpStatus=$(curl -s --head -w %{http_code} https://github.com/$name -o /dev/null)
    if [ $tldCnt -eq 2 ] && [ $httpStatus -ne 200 ]; then
        echo " *$domains available" 
        echo " * https://github.com/$name available" 
    fi
  fi
done
