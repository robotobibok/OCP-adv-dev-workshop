#!/bin/bash
# Reset Production Project (initial active services: Blue)
# This sets all services to the Blue service so that any pipeline run will deploy Green
if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "  $0 GUID"
    exit 1
fi

GUID=$1
echo "Resetting Parks Production Environment in project ${GUID}-parks-prod to Green Services"

# Code to reset the parks production environment to make
# all the green services/routes active.
# This script will be called in the grading pipeline
# if the pipeline is executed without setting
# up the whole infrastructure to guarantee a Blue
# rollout followed by a Green rollout.

# To be Implemented by Student
# Delete the mlbparks blue service
oc delete svc mlbparks-blue -n ${GUID}-parks-prod

# Change MLBparks route
oc patch route/mlbparks -p '{"spec":{"to":{"name":"mlbparks-green"}}}' -n $GUID-parks-prod || echo "MLBParks already green"

# Delete the nationalparks blue service
oc delete svc nationalparks-blue -n ${GUID}-parks-prod

# Change nationalparks route
oc patch route/nationalparks -p '{"spec":{"to":{"name":"nationalparks-green"}}}' -n $GUID-parks-prod || echo "NationalParks already green"

# Delete the parksmap blue service
oc delete svc parksmap-blue -n ${GUID}-parks-prod

# Switch parksmap frontend to green
oc patch route/parksmap -p '{"spec":{"to":{"name":"parksmap-green"}}}' -n $GUID-parks-prod || echo "ParksMap already green"
