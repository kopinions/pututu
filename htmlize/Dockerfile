FROM ubuntu:latest

RUN apt-get update -y \
    && apt-get install -y gnupg2

# xaw7 is for emacs lucid support
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3B4FE6ACC0B21F32 \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 871920D1991BC93C \
    && apt-get install -y libxpm-dev libgif-dev libjpeg-dev libpng-dev libtiff-dev libx11-dev libncurses5-dev automake autoconf texinfo libgtk2.0-dev libgnutls28-dev libxaw7-dev\
    && apt-get install -y gcc-11 g++-11 \
    && apt-get install -y build-essential automake libltdl-dev curl git


ENV CC=/usr/bin/gcc-11
ENV CXX=/usr/bin/gcc-11
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /opt
RUN curl -sjklL http://ftpmirror.gnu.org/emacs/emacs-28.1.tar.gz -o - | tar -zxf - --transform "s/^emacs-28.1/emacs/g" -C /tmp

RUN git clone https://github.com/ImageMagick/ImageMagick.git /tmp/imagemagick

RUN cd /tmp/imagemagick \
    && ./configure --prefix=/opt && make && make install

ENV LD_LIBRARY_PATH=/opt/lib

RUN cd /tmp/emacs \
     && ./autogen.sh \
     && PKG_CONFIG_PATH=/opt/lib/pkgconfig ./configure --with-imagemagick --with-x-toolkit=lucid --prefix=/opt \
     && make -j$(nproc) \
     && make install

FROM ubuntu:latest
COPY --from=0 /opt /opt
ENV PATH=/opt/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/lib

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends libxaw7 libtiff5 libpng16-16 libgif7 libncurses5 libgtk2.0-0 libx11-6 libgnutls-dane0 libsm6 libcurl3-gnutls libgomp1 \
    && apt-get install -y --no-install-recommends graphviz openssl fonts-wqy-microhei texlive-base\
    && apt-get install -y --no-install-recommends openjdk-11-jre-headless \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*
