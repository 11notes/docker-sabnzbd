![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# SABNZBD
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-SABNZBD)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![size](https://img.shields.io/docker/image-size/11notes/sabnzbd/4.5.0?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/sabnzbd/4.5.0?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/sabnzbd?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-SABNZBD?color=7842f5">](https://github.com/11notes/docker-SABNZBD/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxwYXRoIGQ9Im0wIDBoMzJ2MzJoLTMyeiIgZmlsbD0iI2YwMCIvPjxwYXRoIGQ9Im0xMyA2aDZ2N2g3djZoLTd2N2gtNnYtN2gtN3YtNmg3eiIgZmlsbD0iI2ZmZiIvPjwvc3ZnPg==)

Run SABnzbd smaller, lightweight and more secure

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [4.5.0](https://hub.docker.com/r/11notes/sabnzbd/tags?name=4.5.0)
* [4.5.0-unraid](https://hub.docker.com/r/11notes/sabnzbd/tags?name=4.5.0-unraid)

# REPOSITORIES ☁️
```
docker pull 11notes/sabnzbd:4.5.0
docker pull ghcr.io/11notes/sabnzbd:4.5.0
docker pull quay.io/11notes/sabnzbd:4.5.0
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000 causing no issues on unraid. Enjoy.

# SYNOPSIS 📖
**What can I do with this?** This image will give you a rootless and lightweight Radarr installation. Radarr is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! All the other images on the market that do exactly the same don’t do or offer these options:

> [!IMPORTANT]
>* This image runs as 1000:1000 by default, most other images run everything as root
>* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
>* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
>* This image works as read-only, most other images need to write files to the image filesystem
>* This image is smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| ![128px](https://github.com/11notes/defaults/blob/main/static/img/transparent128x1px.png?raw=true)**image** | 11notes/sabnzbd:4.5.0 | linuxserver/sabnzbd:4.5.0 |
| ---: | :---: | :---: |
| **image size on disk** | 165MB | 172MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ❌ | ❌ |
| **rootless?** | ✅ | ❌ |


**Why is this image not distroless?** I would have loved to create a distroless, single binary image. For Python this is a bit tricky though. You can compile Python via clang to a stand-alone binary, but it requires a lot of maintenance which is currently not something I want to do.

# VOLUMES 📁
* **/sabnzbd/etc** - Directory of all your settings and database

# COMPOSE ✂️
```yaml
name: "arrs"
services:
  sabnzbd:
    image: "11notes/sabnzbd:4.5.0"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "sabnzbd.etc:/sabnzbd/etc"
    tmpfs:
      - "/tmp:uid=1000,gid=1000" # required for read-only image
    ports:
      - "8080:8080/tcp"
    networks:
      frontend:
    restart: "always"

volumes:
  sabnzbd.etc:

networks:
  frontend:
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /sabnzbd | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# SOURCE 💾
* [11notes/sabnzbd](https://github.com/11notes/docker-SABNZBD)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [sabnzbd](https://github.com/sabnzbd/sabnzbd)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-sabnzbd/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-sabnzbd/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-sabnzbd/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 30.04.2025, 08:18:01 (CET)*