FROM ubuntu:latest

RUN apt-get update -y \
    && apt-get install -y gnupg2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 \ 
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C \
    && apt-get install -y libgccjit0 libgccjit-10-dev libjansson4 libjansson-dev \
    && apt-get install -y build-essential automake libltdl-dev curl git
ENV CC=/usr/bin/gcc-10
ENV CXX=/usr/bin/gcc-10
ENV DEBIAN_FRONTEND=noninteractive
RUN cat /etc/apt/sources.list && sed -i 's/^# deb-src /deb-src /' /etc/apt/sources.list \
    && cat /etc/apt/sources.list \
    && apt-get update -y \
    && apt-get build-dep -y emacs \
    && curl -sjklL http://ftpmirror.gnu.org/emacs/emacs-28.1.tar.gz -o - | tar -zxf - --transform "s/^emacs-28.1/emacs/g" -C /tmp \
    && cd /tmp/emacs \
    && ./autogen.sh \
    && mkdir /opt/emacs \
    && ./configure --with-native-compilation --prefix=/opt/emacs \
    && make -j$(nproc) \
    && make install \
    && git clone https://github.com/ImageMagick/ImageMagick.git /tmp/imagemagick \
    && mkdir /opt/imagemagick \
    && cd /tmp/imagemagick \
    && ./configure --prefix=/opt/imagemagick && make && make install


FROM ubuntu:latest
RUN apt-get install -y --no-install-recommends graphviz openssl fonts-wqy-microhei texlive-full
COPY --from=0 /opt/emacs /usr
COPY --from=1 /opt/imagemagick /usr
