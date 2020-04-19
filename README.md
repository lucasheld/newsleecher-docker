# Docker container for [NewsLeecher](https://www.newsleecher.com/)

NewsLeecher is a binary Usenet client.

---

## Build

```
$ git clone https://github.com/lucasheld/newsleecher-docker
$ cd newsleecher-docker
$ docker build -t lucasheld/newsleecher .
```

## Usage

```
$ docker run -d \
    --name=newsleecher \
    -p 5800:5800 \
    -p 5900:5900 \
    -e USER_ID=1000 \
    -e GROUP_ID=1000 \
    -v /config-folder-path:"/wine/drive_c/users/app/Application Data/NewsLeecher" \
    lucasheld/newsleecher
```

## Accessing the GUI

Assuming that container's ports are mapped to the same host's ports, the
graphical interface of the application can be accessed via:

- A web browser:

```
http://<HOST-IP>:5800
```

- Any VNC client:

```
<HOST-IP>:5900
```

## More information

More information is avaiable in the [base image repository](https://github.com/jlesage/docker-baseimage-gui).
