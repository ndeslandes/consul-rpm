#!/bin/bash

if [[ -z "$1" ]]; then
  echo $"Usage: $0 <VERSION> [ITER] [ARCH]"
  exit 1
fi

VERSION=$1
ITER=${2:-1}
ARCH=${3:-`uname -m`}

case "${ARCH}" in
  i386)
    ZIP_SERVER=consul_${VERSION}_linux_386.zip
    ;;
  x86_64)
    ZIP_SERVER=consul_${VERSION}_linux_amd64.zip
    ;;
  *)
    echo $"Unknown architecture ${ARCH}" >&2
    exit 1
    ;;
esac

ZIP_UI=consul_${VERSION}_web_ui.zip

curl -k -L -o $ZIP_SERVER https://releases.hashicorp.com/consul/${VERSION}/${ZIP_SERVER} || {
  echo $"URL or version not found for version $VERSION!" >&2
  exit 1
}

curl -k -L -o $ZIP_UI https://releases.hashicorp.com/consul/${VERSION}/${ZIP_UI} || {
  echo $"Web archive not found for version $VERSION!" >&2
  exit 1
}

# clear target foler
rm -rf target

# create target structure
mkdir -p target/usr/local/bin target/etc/init.d target/usr/local/consul
cp -r sources/etc/* target/etc/

# unzip
unzip -qq ${ZIP_SERVER} -d target/usr/local/bin/
unzip -qq ${ZIP_UI} -d target/usr/local/consul/ui

# create rpm
docker run -v $(pwd):$(pwd) -w $(pwd) -t -i fpm-docker \
    fpm -s dir -t rpm -f \
       -C target \
       -n consul-server \
       -v ${VERSION} \
       --iteration ${ITER} \
       -p target \
       -a ${ARCH} \
       --rpm-os linux \
       --rpm-ignore-iteration-in-dependencies \
       --after-install spec/after-install.spec \
       --before-remove spec/before-uninstall.spec \
       --after-remove spec/after-uninstall.spec \
       --description "Consul RPM package" \
       --url "https://github.com/hashicorp/consul" \
       usr/local/bin/consul etc/init.d/consul etc/consul.conf.sample usr/local/consul/ui
