#!/bin/bash

#################################################
# OpenShift Admin utiltiy functions
#################################################

#------------------------------------------------
# help: getResourceValue(resource_type, resource_name, value_path, namespace)
# Returns the value of the resource name specified by a path for a given resource. Use current namespace if the namespace parameter is empty.
#------------------------------------------------
function getResourceValue {
    [ ! -z "${4}" ] && NAME_SPACE=" -n ${4}"
    echo "$(oc get ${1} ${2} ${NAME_SPACE} -o jsonpath='{'${3}'}')"
}

#------------------------------------------------
# help: setResourceValue(resource_type(1), resource_name(2), value_path(3), value(4), namespace(5))
# Returns the value of the resource name specified by a path for a given resource. Use current namespace if the namespace parameter is empty.
#------------------------------------------------
function setResourceValue {
    [ ! -z "${5}" ] && NAME_SPACE=" -n ${5}"

    PATCH_STRING="[{'op': 'replace', 'path': '${3}', 'value': '${4}' }]"
    oc patch ${1} ${2} --type='json' -p="${PATCH_STRING}" ${NAME_SPACE}
}

#------------------------------------------------
# help: getMatchingResources(resource_name(1), pattern(2), namespace(3))
# Get the list of resources where name has the matching patern.
#------------------------------------------------
function getMatchingResources {
    [ ! -z "${3}" ] && NAME_SPACE=" -n ${3}"
    oc get ${1} --no-headers=true -o custom-columns=:metadata.name ${NAME_SPACE} | grep "${2}"
}

#------------------------------------------------
# help: saveResourceManifest(resource_tyep(1), resource_name(2), file_path(3), namespace(4))
# Get the list of resources where name has the matching patern. (Requires kubctl neat plugin installed)
#------------------------------------------------
function saveResourceManifest {
    [ ! -z "${4}" ] && NAME_SPACE=" -n ${4}"
    oc get ${1} ${2} ${NAME_SPACE} -o yaml | kubectl neat > ${3}
}

#------------------------------------------------
# help: waitForStatus(resource_name(1), status_variale(2), status_value(3), time_out(4), namespace(5))
# Waits until the status variable for a k8s resource get the status value or reaches the time out value, whichever occurs first.
#------------------------------------------------
function waitForStatus {

    RESOURCE_NAME="${1}"
    STATUS_VARIABLE="${2}"
    STATUS_VALUE="${3}"
    TIME_OUT="${4}"
    [ ! -z "${5}" ] && NAME_SPACE=" -n ${5}"

    RUN_STATUS_VALUE=""
    WAIT_INTERVAL=10
    TIME_OUT_VALUE=${TIME_OUT%?}
    START_TIME=`date +%s`
    ELAPSED_TIME=0

    while [[ "${RUN_STATUS_VALUE}" != "${STATUS_VALUE}" ]] && [[ "${ELAPSED_TIME}" -lt "${TIME_OUT_VALUE}" ]]
    do
        RUN_STATUS_VALUE=$(oc get ${RESOURCE_NAME} -o jsonpath='{'${STATUS_VARIABLE}'}' ${NAME_SPACE})
        sleep ${WAIT_INTERVAL}
        CURRENT_TIME=`date +%s`
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        echo "Status: ${RUN_STATUS_VALUE}, Waiting for resource ${RESOURCE_NAME} to get the status ${STATUS_VALUE}." 
    done

    if [[ "${RUN_STATUS_VALUE}" == "${STATUS_VALUE}" ]]
    then
        echo "Condition met for ${STATUS_VARIABLE}, now has a value of ${RUN_STATUS_VALUE} and took about ${ELAPSED_TIME}s to compelete."
    else 
        echo "Wait timed out after ${ELAPSED_TIME}s, with current status is ${RUN_STATUS_VALUE}."
        exit 1
    fi
}


#################################################
# Util functions to manage secrets.
#################################################
#------------------------------------------------
# help: createSecret(secret_name(1), username(2), password(3), namespace(4))
# Creates a basic auth secret called secret_name with username and password under a namespace.
#------------------------------------------------
function createSecretBasicAuth {
    [ ! -z "${4}" ] && NAME_SPACE=" -n ${4}"

    oc create secret generic ${1} \
    --from-literal=username=${2} \
    --from-literal=password=${3} \
    --type=kubernetes.io/basic-auth \
    ${NAME_SPACE}
}

#------------------------------------------------
# help: getSecretValue(secret_name(1), value_path(2), namespace(3))
# Returns the base64 decoded value of an Opaque secret. Use current namespace if the namespace parameter is empty.
#------------------------------------------------
function getSecretValue {
    getResourceValue "secret" $@ | base64 --decode
}

#------------------------------------------------
# help: setSecretValue(secret_name(1), value_path(2), value(3), namespace(4))
# Set the Opaque secret value for a secret. Use default namespace if the namespace parameter is empty.
#------------------------------------------------
function setSecretValue {
    setResourceValue "secret" $@
}
