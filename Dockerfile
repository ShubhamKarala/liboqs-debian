FROM debian:testing-slim

ARG debian_control_path

RUN apt update \
 && apt install --no-install-recommends -yV \
    build-essential \
    devscripts \
    equivs \
    wget

WORKDIR /build/
RUN wget https://github.com/open-quantum-safe/liboqs/archive/refs/tags/0.7.2.tar.gz
RUN echo "8432209a3dc7d96af03460fc161676c89e14fca5aaa588a272eb43992b53de76 0.7.2.tar.gz" | sha256sum --check --status
RUN tar -zxvf 0.7.2.tar.gz

COPY ./debian/ liboqs-0.7.2/debian/

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

# Install the build deps for _this_ package
RUN mk-build-deps -irt 'apt-get --no-install-recommends -yV' liboqs-0.7.2/debian/control

RUN echo '#!/bin/sh\n\
set -x\n\
cd /build/liboqs-0.7.2\n\
debuild -b -uc -us -nc\n\
mv ../*.deb /output\n'\
>> /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
