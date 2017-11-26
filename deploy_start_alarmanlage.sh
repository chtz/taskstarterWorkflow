#!/bin/bash

#Pre-conds (env vars): IFTTT_KEY

export DEF_ID=`curl -s --data-binary @alarmanlage.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Workflow definition created: $DEF_ID
 
export WF_ID=`curl -s --data-binary "{\"iftttKeyx\":\"$IFTTT_KEY\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/definitions/$DEF_ID`

echo Workflow instance started: $WF_ID

export WF_ID=`curl -s --data-binary "{\"wfidx\":\"$WF_ID\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/instances/$WF_ID`

echo Workflow instance signaled: $WF_ID

export CONFIG_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "notifyInit")' | jq -r '.vars.id')
export ALARM_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "presenceInit")' | jq -r '.vars.id')

echo Config token obtained: $CONFIG_TOKEN_ID
echo Alarm token obtained: $ALARM_TOKEN_ID

export WF_ID=$(curl -s -d "{}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$ALARM_TOKEN_ID)

echo Alarm loop activated

cat >ifttt_notify.sh <<EOL
#!/bin/bash
curl -s -d "{\"presence\":\"\$1\"}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$ALARM_TOKEN_ID
EOL

echo Alarm script created: ifttt_notify.sh

export WF_ID=$(curl -s -d "{}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$CONFIG_TOKEN_ID)

echo Config loop activated

./target.sh "https://pmw.furthermore.ch/tokensX/$WF_ID/$CONFIG_TOKEN_ID" > /dev/null

echo IFTTT mystrom applet \(indirectly\) adjusted to new target:
echo https://pmw.furthermore.ch/tokensX/$WF_ID/$CONFIG_TOKEN_ID

scp ifttt_notify.sh ubuntee2.local:~/hue/scripts/ifttt_notify.sh

echo HUE alert script replaced
