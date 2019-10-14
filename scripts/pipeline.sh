#!/bin/bash

source variables.sh

# ci-cd setup
oc project ${NAMESPACE}-ci-cd
oc create -n ${NAMESPACE}-ci-cd -f ../pipeline.yaml

# dev setup
oc project ${NAMESPACE}-dev
oc new-app --name=cotd-app openshift/php:5.6~https://github.com/HCL-Cloud-Native-Labs/cotd.git#master
oc expose svc cotd-app --name=cotd-app --hostname=${NAMESPACE}-cotd-app-development.apps.ocp.uk.hclcnlabs.com

# test setup
oc project ${NAMESPACE}-test
oc create dc cotd-app --image=docker-registry.default.svc:5000/${NAMESPACE}-dev/cotd-app:promoteQA
oc patch dc cotd-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"default-container","imagePullPolicy":"Always"}]}}}}'
oc expose dc cotd-app --port=8080
oc expose svc cotd-app --name=cotd-app --hostname=${NAMESPACE}-cotd-app-testing.apps.ocp.uk.hclcnlabs.com

# prod setup
oc project ${NAMESPACE}-prod
oc create dc cotd-app --image=docker-registry.default.svc:5000/${NAMESPACE}-dev/cotd-app:promotePRD
oc patch dc cotd-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"default-container","imagePullPolicy":"Always"}]}}}}'
oc expose dc cotd-app --port=8080
oc expose svc cotd-app --name=cotd-app --hostname=${NAMESPACE}-cotd-app-production.apps.ocp.uk.hclcnlabs.com

# ultrahook setup
oc project ${NAMESPACE}-ci-cd
oc apply -f ../../ultrahook-openshift/openshift/ultrahook.app.yaml
oc process -f ../../ultrahook-openshift/openshift/ultrahook.secret.yaml ULTRAHOOK_API_KEY='ZjRrNHZxUU5meGE4WnBpVE9RMTdqVG5oR2ZSdW5za2I=' | oc apply -f -
oc process ultrahook ULTRAHOOK_SUBDOMAIN=github ULTRAHOOK_DESTINATION=https://openshift.uk.hclcnlabs.com:8443 | oc apply -f -
