#!/bin/bash
htmlfile=$1

contents=$(<$1)
echo "CW2 Jennifer Gates"
echo "Parse HTML Exercise"
echo "Parsing HTML File $1"

declare -a greps=(
"grep -E '^<link'"
"grep -Eo 'OWASP'"
"grep -Eo '<div'"
"grep -E '^<div'"
"grep -Eo '<\/script>'"
"grep -Eo '<\/script>$'"
"grep -Eo '<head>'"
"grep -Eo 'https?:\/\/'"
"grep -Eo 'https?:\/\/[^< >\"]*' | sort -u"
"grep -Eo '[a-zA-Z0-9\.\-_]*(@|\(at\))([a-zA-Z0-9]*\.)+[^: <>\";),]*'"
"grep -Eo '[a-zA-Z0-9\.\-_]*(@|\(at\))([a-zA-Z0-9]*\.)+[^: <>\";),]*' | sort -u "
"grep -Eo '\(?\d\d\d\)?(\d\d\d)[\.\-](\d\d\d\d)'"
"grep -Eo 'CWE-\d+'"
"grep -Eo 'CWE-\d+'| sort -u"
	)

INDEX=1
for g in "${greps[@]}"
do
	echo " "
	echo "FLAG: ${INDEX}"
	echo "COMMAND: cat $1 | $g | wc -l | awk '{print $1}' | openssl md5 "
	echo -n "HASH:";	
	echo "$contents" | eval "$g" | wc -l | awk '{print $1}' | openssl md5
	let INDEX=${INDEX}+1

done

