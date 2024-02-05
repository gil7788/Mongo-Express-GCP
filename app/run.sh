#!/bin/sh
echo "Hello, world! The time is $(date)."

echo "Installing darkhttpd..."
# Install darkhttpd
apk add --no-cache darkhttpd
echo "darkhttpd installed."

echo "Serving files..."
# Serve files from the current directory on port 8080 in the background
darkhttpd . --port 8080 &

# Sleep for 10 seconds
sleep 10

# Terminate the darkhttpd server after 10 seconds
killall darkhttpd

echo "Files served!"
