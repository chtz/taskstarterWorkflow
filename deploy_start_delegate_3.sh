#!/bin/bash

export DEF_ID=`curl -s --data-binary @delegate_3.pmsl -H'Content-Type:text/plain' https://pmw.furthermore.ch/definitions`

echo Workflow definition created: $DEF_ID
 
export WF_ID=`curl -s --data-binary "{}" -H'Content-Type:application/json' https://pmw.furthermore.ch/definitions/$DEF_ID`

echo Workflow instance started: $WF_ID

export CONFIG_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "configLoop")' | jq -r '.vars.id')
export DELEGATE_TOKEN_ID=$(curl -s https://pmw.furthermore.ch/instances/$WF_ID | jq '.children[] | select(.node == "delegateLoop")' | jq -r '.vars.id')

echo Config token obtained: $CONFIG_TOKEN_ID

cat >target_3.sh <<EOL
#!/bin/bash
curl -s -d "{\"config\":\"\$1\"}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$CONFIG_TOKEN_ID
EOL

echo Config script created: target_3.sh

echo Delegate token obtained: $DELEGATE_TOKEN_ID

cat >delegate_3.sh <<EOL
#!/bin/bash
curl -s -d "{\"geo\":\"\$1\",\"event\":\"\$2\"}" -H 'Content-Type: application/json;charset=utf-8' https://pmw.furthermore.ch/tokens/$WF_ID/$DELEGATE_TOKEN_ID
EOL

cat >delegate_3.url <<EOL
https://pmw.furthermore.ch/tokensX/$WF_ID/$DELEGATE_TOKEN_ID
EOL

echo Delegate script created: delegate_3.sh
