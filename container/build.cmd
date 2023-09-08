cd ..
docker build --pull --rm -f "container\dockerfile" -t klaspihl/unlocode:latest "src" 

docker push klaspihl/unlocode:latest
docker rmi $(docker images -f "dangling=true" -q)