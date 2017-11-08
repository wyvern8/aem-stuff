#!/bin/bash

# requires jq from https://stedolan.github.io/jq

display_usage() {
    echo "This script must be run with aem url, user, pass"
    echo "eg. ./extractAemAuthorizables.sh http://localhost:4502 admin admin"
}

if [ $# -eq 0 ]; then
    display_usage
    exit 1
fi

curl -s -u $2:$3 "$1/bin/querybuilder.json?path=/home&p.limit=-1&p.hits=full&property=jcr:primaryType&property.1_value=rep:Group&property.2_value=rep:User" 2>&1 | sed 's/jcr\://g' | sed 's/rep\://g' |jq '.hits | map([.primaryType, .principalName, .path] | join(", ")) | join("\n")' | sed 's/\\n/\n/g' | sed 's/"//g' | sort
