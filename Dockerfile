FROM alpine:3.3
MAINTAINER paolo.mainardi@sparkfabrik.com
ENV DEBIAN_FRONTEND noninteractive

# Download and install hugo
ENV HUGO_VERSION 0.15
ENV HUGO_BINARY hugo_${HUGO_VERSION}_linux_amd64
ENV PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz /usr/local/
RUN tar xzf /usr/local/${HUGO_BINARY}.tar.gz -C /usr/local/ \
  && ln -s /usr/local/${HUGO_BINARY}/${HUGO_BINARY} /usr/local/bin/hugo \
  && rm /usr/local/${HUGO_BINARY}.tar.gz

# Create working directory
RUN mkdir /app
WORKDIR /app

# Automatically build site
ADD src/ /app
RUN hugo -d /app

# By default, serve site
EXPOSE 8080
ENV HUGO_URL 0.0.0.0
ENV HUGO_PORT 8080
CMD hugo server --bind ${HUGO_URL} --port=${HUGO_PORT} --buildDrafts --theme=default
