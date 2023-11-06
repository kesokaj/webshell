````
docker build -t ghcr.io/kesokaj/webshell:v<VERSION> -t ghcr.io/kesokaj/webshell:latest .
docker run -it --privileged  -d -p 3000:3000 -v "$PWD/workspace:/usr/local/workspace" ghcr.io/kesokaj/webshell:latest
docker push ghcr.io/kesokaj/webshell --all-tags
````
