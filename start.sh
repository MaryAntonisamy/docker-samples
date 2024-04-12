#!/bin/bash
# Start the API in the background
dotnet ./api/MyApi.dll &

# Start the background service in the background
dotnet ./worker/MyWorker.dll &

# Wait for any process to exit
wait -n

# Exit with the status of the process that exited first
exit $?
