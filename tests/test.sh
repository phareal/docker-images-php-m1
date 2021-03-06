#!/usr/bin/env bash

set -xe

docker buildx build --platform=linux/amd64 --load -t phareal/node-m1:latest -f .

# Default user is 1000
RESULT=`docker run --rm phareal/node-m1:latest id -ur`
[[ "$RESULT" = "1000" ]]

# If mounted, default user has the id of the mount directory
mkdir user1999 && sudo chown 1999:1999 user1999
ls -al user1999
RESULT=`docker run --rm -v $(pwd)/user1999:$CONTAINER_CWD phareal/node-m1:latest id -ur`
[[ "$RESULT" = "1999" ]]
sudo rm -rf user1999

# Let's check that the crons are actually sending logs in the right place
RESULT=`docker run --rm -e CRON_SCHEDULE_1="* * * * * * *" -e CRON_COMMAND_1="(>&1 echo "foobar")" phareal/node-m1:latest sleep 1 2>&1 | grep -oP 'msg=foobar' | head -n1`
[[ "$RESULT" = "msg=foobar" ]]

RESULT=`docker run --rm -e CRON_SCHEDULE_1="* * * * * * *" -e CRON_COMMAND_1="(>&2 echo "error")" phareal/node-m1:latest sleep 1 2>&1 | grep -oP 'msg=error' | head -n1`
[[ "$RESULT" = "msg=error" ]]

# Let's check that the cron with a user different from root is actually run.
RESULT=`docker run --rm -e CRON_SCHEDULE_1="* * * * * * *" -e CRON_COMMAND_1="whoami" -e CRON_USER_1="docker" phareal/node-m1:latest sleep 1 2>&1 | grep -oP 'msg=docker' | head -n1`
[[ "$RESULT" = "msg=docker" ]]

echo "Tests passed with success"