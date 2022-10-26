````
docker build -t ghcr.io/kesokaj/webshell:v1 .
docker run -it --privileged  -d -p 8080:80 -v "$PWD/home:/home" -e SHELL_USER=user -e SHELL_PASSWORD=user ghcr.io/kesokaj/webshell:v1
docker push ghcr.io/kesokaj/webshell:v1
````
