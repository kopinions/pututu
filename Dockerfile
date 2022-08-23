FROM silex/nix

ADD https://api.github.com/repos/Silex/nix-emacs-ci/commits\?per_page\=1 /tmp/cache
RUN nix-env -iA emacs-28-1 -f https://github.com/silex/nix-emacs-ci/archive/master.tar.gz
RUN nix copy --no-require-sigs --to /nix-emacs $(type -p emacs)
RUN cd /nix-emacs/nix/store && ln -s *emacs* emacs

FROM ubuntu:latest
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y build-essential automake libltdl-dev \
    && apt-get install -y git \
    && git clone https://github.com/ImageMagick/ImageMagick.git /tmp/imagemagick \
    && cd /tmp/imagemagick \
    && ./configure --prefix=/opt/imagemagick && make && make install


FROM ubuntu:latest
RUN apt-get install -y --no-install-recommends graphviz openssl fonts-wqy-microhei texlive-full
COPY --from=0 /nix-emacs/nix/store /nix/store
COPY --from=1 /opt/imagemagick /usr
ENV PATH="/nix/store/emacs/bin:$PATH"
