${{ content_synopsis }} This image will give you a rootless and lightweight SABnzbd installation. SABnzbd is an Open Source Binary Newsreader written in Python.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem
${{ github:> }}* This repository has an auto update feature that will automatically build the latest version if released, most other providers don't do this
${{ github:> }}* This image is smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}

**Why is this image not distroless?** I would have loved to create a distroless, single binary image. For Python this is a bit tricky though. You can compile Python via clang to a stand-alone binary, but it requires a lot of maintenance which is currently not something I want to do.

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of all your settings and database

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}