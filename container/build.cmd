cd ..
docker build --pull --rm -f "container\dockerfile" -t unlocode:lts-alpine-3.14 "src" 
docker rmi $(docker images -f "dangling=true" -q)