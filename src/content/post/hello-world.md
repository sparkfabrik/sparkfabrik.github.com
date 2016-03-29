+++
date = "2016-03-23T16:31:55Z"
draft = false
title = "Hello world"
description = "Subtitle of the post (also used as meta description)"
+++

Hello world, posts are coming.

~~~php
/**
 * Gathers a listing of links to nodes.
 *
 * @param $result
 *   A database result object from a query to fetch node entities. If your
 *   query joins the {node_comment_statistics} table so that the comment_count
 *   field is available, a title attribute will be added to show the number of
 *   comments.
 * @param $title
 *   A heading for the resulting list.
 *
 * @return
 *   A renderable array containing a list of linked node titles fetched from
 *   $result, or FALSE if there are no rows in $result.
 */
function node_title_list($result, $title = NULL) {
  $items = array();
  $num_rows = FALSE;
  foreach ($result as $node) {
    $items[] = l($node->title, 'node/' . $node->nid, !empty($node->comment_count) ? array('attributes' => array('title' => format_plural($node->comment_count, '1 comment', '@count comments'))) : array());
    $num_rows = TRUE;
  }

  return $num_rows ? array('#theme' => 'item_list__node', '#items' => $items, '#title' => $title) : FALSE;
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

