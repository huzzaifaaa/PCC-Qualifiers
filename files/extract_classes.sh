#!/bin/bash
set -e

# Compile
javac ClassDumper.java


# Create JAR 
jar cmf manifest.txt dumper.jar ClassDumper*.class

# Cleanup
rm -f ClassDumper.java ClassDumper*.class manifest.txt


docker build -t ctf-dumper .


# Clean up any existing container
docker rm -f ctf-dumper-run 2>/dev/null || true

docker run -d --name ctf-dumper-run -p 8080:8080 ctf-dumper

# Wait a moment to see if it crashes immediately
sleep 3

# Check if container is running
if ! docker ps | grep -q ctf-dumper-run; then
    docker logs ctf-dumper-run
    exit 1
fi

# Waiting for application to start (30 seconds)
sleep 30

# Show ClassDumper output

docker logs ctf-dumper-run 2>&1 | grep "\[ClassDumper\]" || echo "No ClassDumper output yet"

# Check if dumped directory exists

DUMP_CHECK=$(docker exec ctf-dumper-run find /app/dumped -name "*.class" 2>/dev/null | wc -l)
echo "Found $DUMP_CHECK class files so far"

# Trigger some endpoints to load more classes

curl -s http://localhost:8080/ > /dev/null 2>&1 && echo "- Hit /" || echo "- / failed"
curl -s http://localhost:8080/premium > /dev/null 2>&1 && echo "- Hit /premium" || echo "- /premium failed"
curl -s http://localhost:8080/api > /dev/null 2>&1 && echo "- Hit /api" || true
curl -s http://localhost:8080/health > /dev/null 2>&1 && echo "- Hit /health" || true

# Wait for classes to be loaded
sleep 10

# Check dumped classes again
docker exec ctf-dumper-run find /app/dumped -name "*.class" 2>/dev/null || echo "No dumped directory found"

# Show all ClassDumper output
docker logs ctf-dumper-run 2>&1 | grep "ClassDumper" || echo "No ClassDumper output"

# Copy classes
docker cp ctf-dumper-run:/app/dumped ./decrypted_classes 2>&1

