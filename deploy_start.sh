#!/bin/bash

#Pre-conds (env vars): IFTTT_KEY, EMAIL

export SUB_DEF_ID=`curl -s --data-binary @taskstarter.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Sub-workflow definition created: $SUB_DEF_ID
 
export DEF_ID=`curl -s --data-binary @sample.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Workflow definition created: $DEF_ID
 
export WF_ID=`curl -s --data-binary "{\"subWfId\":\"$SUB_DEF_ID\",\"iftttKey\":\"$IFTTT_KEY\",\"email\":\"$EMAIL\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/definitions/$DEF_ID`

echo Workflow instance started: $WF_ID
