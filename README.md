docker-wildfly-http2
====================

[Wildfly](http://wildfly.org) 9.0.0.Beta1 with HTTP/2 support, as described here: http://undertow.io/blog/2015/03/26/HTTP2-In-Wildfly.html

This image is used for the first example in my [HTTP/2 blog](http://fstab.github.io/h2c/).

In addition to enabling HTTP/2 on port `8443`, the image also enables the admin console on port `9990`, accessable with username _admin_ and password _admin_.

How To Run
----------

The image is available on [Docker Hub](https://registry.hub.docker.com/u/fstab/wildfly-http2), and can be downloaded and run with a single command.

On Linux, run it as folows:

```bash
docker run -t -i fstab/wildfly-http2:9.0.0.Beta1
```

If you are using [boot2docker](http://boot2docker.io) on Windows or Mac, you need additional parameters to publish the ports on the boot2docker VM:

```bash
docker run -t -p 8443:8443 -p 9990:9990 -i fstab/wildfly-http2:9.0.0.Beta1
```

Wildfly becomes available on [https://IP_ADDRESS:8443](https://XXX.XXX.XXX.XXX:8443) where _IP_ADDRESS_ depends on if you are using boot2docker or not.

On Linux, the IP_ADDRESS is the address of the Docker container, which you can find out by first running `docker ps` to learn the container ID, and then `docker inspect <id>` to get the IP address.

With [boot2docker](http://boot2docker.io), the IP address can be found with the command `boot2docker ip`.

Building the Docker Image from Source
-------------------------------------

1. Make sure [Docker](https://www.docker.com) is installed.
    
2. Clone [fstab/docker-wildfly-http2](https://github.com/fstab/docker-wildfly-http2) from GitHub.
    
    ```bash
    git clone https://github.com/fstab/docker-wildfly-http2.git
    ```
    
3. Build the docker image
    
    ```bash
    cd docker-wildfly-http2
    docker build -t="fstab/wildfly-http2:9.0.0.Beta1" .
    ```
