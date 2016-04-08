FROM alpine:3.3
MAINTAINER paolo.mainardi@sparkfabrik.com
RUN apk add --no-cache vim py-pip python && \
  pip install Pygments

# Download and install hugo
ENV HUGO_VERSION 0.15
ENV HUGO_BINARY hugo_${HUGO_VERSION}_linux_amd64
ENV PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '

ADD https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz /usr/local/
RUN tar xzf /usr/local/${HUGO_BINARY}.tar.gz -C /usr/local/ \
  && ln -s /usr/local/${HUGO_BINARY}/${HUGO_BINARY} /usr/local/bin/hugo \
  && rm /usr/local/${HUGO_BINARY}.tar.gz

# Create working directory
VOLUME /app
WORKDIR /app

# Add sources.
ADD src/ /app
ADD scripts/build.sh /usr/local/bin/build
RUN chmod +x /usr/local/bin/build

# By default, serve site.
EXPOSE 1313 35729
ENV HUGO_URL 0.0.0.0
CMD hugo server --bind ${HUGO_URL} --buildDrafts --theme=spark --baseUrl=tech.sparkfabrik.loc
