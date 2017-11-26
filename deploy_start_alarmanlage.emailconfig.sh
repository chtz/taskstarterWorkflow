#!/bin/bash

#Pre-conds (env vars): IFTTT_KEY, EMAIL

export DEF_ID=`curl -s --data-binary @alarmanlage.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Workflow definition created: $DEF_ID
 
export WF_ID=`curl -s --data-binary "{\"iftttKeyx\":\"$IFTTT_KEY\",\"emailx\":\"$EMAIL\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/definitions/$DEF_ID`

echo Workflow instance started: $WF_ID

export WF_ID=`curl -s --data-binary "{\"wfidx\":\"$WF_ID\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/instances/$WF_ID`

echo Workflow instance signaled: $WF_ID
