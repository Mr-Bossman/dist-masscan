#Docker file and server to scan the web

### Command to start docker container
```
$ sudo podman build --cap-add ALL  -t masscan .
```

### Command to start server to start and enumerate containers
```
$ npm i
$ node .
```

