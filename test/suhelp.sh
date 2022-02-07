#!/bin/bash

#################################################
# Test suite for OpenShift Admin utiltiy functions
#################################################

#------------------------------------------------
# help: help(function_name)
# Display help information for the function name.
#------------------------------------------------
function help {
    FUNCTION_NAME="help.*${1}"
    echo
    grep -i -A 1 --color "${FUNCTION_NAME}" ../lib/*.sh
    echo
}

help $1




