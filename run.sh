#!/bin/bash

# TODO: configure
# THUNDRA_APIKEY=...
FUNC_NAME=thundra-localstack
AGENT_URL=https://repo.thundra.io/service/local/artifact/maven/redirect?r=thundra-releases&g=io.thundra.agent&a=thundra-agent-lambda-layer&v=LATEST
USE_AGENT=1

test -e lib/thundra-agent.jar || wget -O lib/thundra-agent.jar "$AGENT_URL"

zip -r lambda.zip lib

if [ "$USE_AGENT" = "1" ]; then
    awslocal lambda create-function --function-name $FUNC_NAME \
      --handler cloud.localstack.sample.LambdaHandlerWithLib \
      --zip-file fileb://./lambda.zip \
      --runtime java11 \
      --role test \
      --timeout 10 \
      --environment \
       Variables="{THUNDRA_APIKEY=$THUNDRA_APIKEY,JAVA_TOOL_OPTIONS=-javaagent:lib/thundra-agent.jar}"
else
     awslocal lambda create-function --function-name $FUNC_NAME \
       --handler io.thundra.agent.lambda.core.handler.ThundraLambdaHandler \
       --zip-file fileb://./lambda.zip \
       --runtime java11 \
       --role test \
       --environment Variables="{THUNDRA_APIKEY=$THUNDRA_APIKEY,THUNDRA_AGENT_LAMBDA_HANDLER=cloud.localstack.sample.LambdaHandlerWithLib}" \
       --tracing-config Mode=Active
fi

awslocal lambda invoke --function-name $FUNC_NAME --payload '{"test":123}' /tmp/test.out
