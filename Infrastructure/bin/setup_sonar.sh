#!/bin/bash
# Setup Sonarqube Project
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Setting up Sonarqube in project $GUID-sonarqube"

# Code to set up the SonarQube project.
# Ideally just calls a template
# oc new-app -f ../templates/sonarqube.yaml --param .....

# To be Implemented by Student

oc new-app --template=postgresql-persistent --param POSTGRESQL_USER=sonar --param POSTGRESQL_PASSWORD=sonar --param POSTGRESQL_DATABASE=sonar --param VOLUME_CAPACITY=4Gi --labels=app=sonarqube_db -n $GUID-sonarqube
oc new-app --docker-image=wkulhanek/sonarqube:6.7.4 --env=SONARQUBE_JDBC_USERNAME=sonar --env=SONARQUBE_JDBC_PASSWORD=sonar --env=SONARQUBE_JDBC_URL=jdbc:postgresql://postgresql/sonar --labels=app=sonarqube -n $GUID-sonarqube

oc rollout pause dc sonarqube -n $GUID-sonarqube
oc expose service sonarqube -n $GUID-sonarqube
oc create -f ./Infrastructure/templates/sonarqube/pvc.yaml -n $GUID-sonarqube
oc set volume dc/sonarqube --add --overwrite --name=sonarqube-volume-1 --mount-path=/opt/sonarqube/data/ --type persistentVolumeClaim --claim-name=sonarqube-pvc -n $GUID-sonarqube
oc set resources dc/sonarqube --limits=memory=3Gi,cpu=2 --requests=memory=2Gi,cpu=1 -n $GUID-sonarqube
oc patch dc sonarqube --patch='{ "spec": { "strategy": { "type": "Recreate" }}}' -n $GUID-sonarqube
oc set probe dc/sonarqube -n $GUID-sonarqube --liveness --failure-threshold 3 --initial-delay-seconds 40 -- echo ok
oc set probe dc/sonarqube -n $GUID-sonarqube --readiness --failure-threshold 3 --initial-delay-seconds 60 --get-url=http://:9000/about
oc rollout resume dc sonarqube -n $GUID-sonarqube

oc policy add-role-to-user edit system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-sonarqube
oc policy add-role-to-user admin system:serviceaccount:gpte-jenkins:jenkins -n ${GUID}-sonarqube
