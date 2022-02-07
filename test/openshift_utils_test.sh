#!/bin/bash

#################################################
# Test suite for OpenShift Admin utiltiy functions
#################################################

source ../lib/openshift_utils.sh

TEST_PROJECT="shellutils-test"

echo "Creating the test project: shellutils-test"
oc new-project ${TEST_PROJECT}

echo "Creating a secret 'su-secret-one'"
createSecretBasicAuth "su-secret-one" "sh-user" "here-is-the-secret-value"

echo "Getting username for the secret 'su-secret-one': $(getSecretValue "su-secret-one" ".data.username" ${TEST_PROJECT})"
echo "Getting password for the secret 'su-secret-one': $(getSecretValue "su-secret-one" ".data.password" ${TEST_PROJECT})"

echo "Updating password to a new value:"
NEW_PASSWD=$(echo "new-password-value-for-secret" | base64)
setSecretValue "su-secret-one" "/data/password" "${NEW_PASSWD}" ${TEST_PROJECT}
echo "Getting password for the secret 'su-secret-one': $(getSecretValue "su-secret-one" ".data.password" ${TEST_PROJECT})"

echo "Deleting the test project: shellutils-test"
oc delete project "shellutils-test"
