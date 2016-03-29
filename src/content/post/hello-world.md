+++
date = "2016-03-23T16:31:55Z"
draft = false
title = "Hello world"
description = "Subtitle of the post (also used as meta description)"
+++

Hello world, posts are coming.

~~~php
/**
 * Implements hook_init().
 */
function elite_base_init() {
  module_load_include('inc', 'token', 'token.tokens');
  drupal_add_js(drupal_get_path('module', 'elite_base') . '/js/elite_base_utils.js');
  $cur_domain = elite_base_get_domain();
  if ($cur_domain['elite_type'] === 'elite_exchange') {
    drupal_add_js(drupal_get_path('module', 'elite_base') . '/js/elite_base_ec_modals.js');
  }
  if ($plugin = context_get_plugin('condition', 'elite_base_elite_domain_type')) {
    $plugin->execute();
  }
}
~~~

~~~docker
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
EXPOSE 80
ENV HUGO_URL 0.0.0.0
ENV HUGO_PORT 80
CMD hugo server --bind ${HUGO_URL} --port=${HUGO_PORT} --buildDrafts --renderToDisk=true  --theme=spark --baseUrl=tech.sparkfabrik.loc
~~~

