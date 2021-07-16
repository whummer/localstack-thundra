#!/bin/bash

FUNC_NAME=thundra-localstack
THUNDRA_APIKEY=...
AGENT_URL=https://repo.thundra.io/service/local/artifact/maven/redirect?r=thundra-releases&g=io.thundra.agent&a=thundra-agent-lambda-layer&v=LATEST

test -e lib/thundra-agent.jar || wget -O lib/thundra-agent.jar "$AGENT_URL"

zip -r lambda.zip lib

awslocal lambda create-function --function-name $FUNC_NAME \
  --handler io.thundra.agent.lambda.core.handler.ThundraLambdaHandler \
  --zip-file fileb://./lambda.zip \
  --runtime java11 \
  --role test \
  --timeout 10 \
  --environment \
   Variables="{THUNDRA_APIKEY=$THUNDRA_APIKEY,THUNDRA_AGENT_LAMBDA_HANDLER=cloud.localstack.sample.LambdaHandlerWithLib}"

awslocal lambda invoke --function-name $FUNC_NAME --payload '{"test":123}' /tmp/test.out
