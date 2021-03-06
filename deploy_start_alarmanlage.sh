#!/bin/bash

#Pre-conds (env vars): IFTTT_KEY

export DEF_ID=`curl -s --data-binary @alarmanlage.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Workflow definition created: $DEF_ID

export NOTIFY_URL=$(cat delegate_2.url)

export WF_ID=`curl -s --data-binary "{\"notifyUrl\":\"$NOTIFY_URL\"}" -H'Content-Type:application/json' https://pmw.furthermore.ch/definitions/$DEF_ID`

echo Workflow instance started: $WF_ID

export WF_ID=`curl -s --data-binary "{}" -H'Content-Type:application/json' https://pmw.furthermore.ch/instances/$WF_ID`

echo Workflow instance signaled: $WF_ID

export CONFIG_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "notifyInit")' | jq -r '.vars.id')
export ALARM_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "presenceInit")' | jq -r '.vars.id')
export GEO_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "geoInit")' | jq -r '.vars.id')

echo Config token obtained: $CONFIG_TOKEN_ID
echo Alarm token obtained: $ALARM_TOKEN_ID
echo Geo token obtained: $GEO_TOKEN_ID

export WF_ID=$(curl -s -d "{}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$ALARM_TOKEN_ID)

echo Alarm loop activated

cat >ifttt_notify.sh <<EOL
#!/bin/bash
curl -s -d "{\"presence\":\"\$1\"}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$ALARM_TOKEN_ID
EOL

echo Alarm script created: ifttt_notify.sh

export WF_IDx=$(curl -s -d "{}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$CONFIG_TOKEN_ID)

echo Config loop activated

./target.sh "https://pmw.furthermore.ch/tokensX/$WF_ID/$CONFIG_TOKEN_ID" > /dev/null

echo IFTTT mystrom applet \(indirectly\) adjusted to new target:
echo https://pmw.furthermore.ch/tokensX/$WF_ID/$CONFIG_TOKEN_ID

scp ifttt_notify.sh 192.168.178.25:~/hue/scripts/ifttt_notify.sh

echo HUE alert script replaced

#

export WF_IDx=$(curl -s -d "{}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$GEO_TOKEN_ID)

echo Geo loop activated

./target_3.sh "https://pmw.furthermore.ch/tokensX/$WF_ID/$GEO_TOKEN_ID" > /dev/null

echo Geo target 3 adjusted to new geo target:
echo https://pmw.furthermore.ch/tokensX/$WF_ID/$GEO_TOKEN_ID
