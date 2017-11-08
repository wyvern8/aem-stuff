#!/bin/bash

# requires jq from https://stedolan.github.io/jq

display_usage() {
    echo "This script must be run with aem url, user, pass"
    echo "eg. ./extractAemAuthorizables.sh http://localhost:4502 admin admin"
}

if ! type "jq" > /dev/null; then
    echo "This script requires the 'jq' command installed on path from https://stedolan.github.io/jq"
    exit 1
fi

if [ $# -lt 3 ]; then
    display_usage
    exit 1
fi

echo "type, principalName, path"
# curl aem querybuilder requesting nodes under /home of jcr:primaryType = rep:Group or rep:User ..
curl -skG -u $2:$3 "$1/bin/querybuilder.json" \
-d "path=/home&p.limit=-1&p.hits=full&property=jcr:primaryType&property.1_value=rep:Group&property.2_value=rep:User" \
2>&1 | sed 's/jcr\://g' | sed 's/rep\://g' | # ..strip attribute namespaces causing jq to choke when mapping..
jq '.hits | map([.primaryType, .principalName, .path] | join(", ")) | join("\n")' | # .. and use jq to map results to csv..
sed 's/\\n/\n/g' | sed 's/"//g' | sort # .. then clean up csv linefeeds and quotes, and sort. done!

# write to csv file with: ./extractAemAuthorizables.sh http://localhost:4502 admin admin > usersAndGroups.csv
