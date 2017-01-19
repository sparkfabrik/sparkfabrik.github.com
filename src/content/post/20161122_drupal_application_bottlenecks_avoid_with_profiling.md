+++
date = "2016-11-22T11:02:30Z"
draft = false
title = "Avoid bottlenecks on a Drupal web application and how identify it with profiling"
description = "How identify bottleneck of your web application and avoid that can appear in the future"
tags        = [ "profiling", "drupal", "performance", "web application"  ]
topics      = [ "Profiling", "Drupal", "Performance" ]
author = "Vinz"
+++

## Introdution

This article is focused on the possible *bottlenecks of a web application*, how you can identify it and improve the performance of your code.

We'll talk about using *Blackfire* to get insights on a Drupal-based PHP application running on a LAMP stack.

<!-- more -->

Application's performance is one of the feature that tells a *done* job from a *good* job, and shows a focus on quality.

Scope of this post it to provide a quick-reference that can be used right before to deploying a Drupal (but not only) project to production.
There are two kind of actions that can improve performances: application of best-pratices, that aren't related to product's functions and the logic profiling that depends on domain and the implementation (that can be considered cherry on top).

We will provide:

* A list of checks, valid for every PHP application, with indication which Drupal components are involved, point by point.
* Tools and methods useful to obtain information about how our application is performing and where bottlenecks are located. 
* A pratical example on how to find improvement points and apply necessary changes.
* Some pro-tips dictated by experience on common pitfall and how bypass them. 

### Performance best-practice checklist

At first level of the list we can see "general" checks that we can perform for a generic web application, at the second level a Drupal transliteration of the point.

1. Check that caches are active and working

   *In Drupal*: Activate page cache, block cache and view cache as the miniumum set.

2. Aggregate and minify CSS and JS to improve bandwidth consumption.

   *In Drupal*: A good starting point are to use the tools provided by our favourite CMF in the `development - performance` section.

3. Deactivate development component: all frameworks provide a set of useful tolls/function to help developers but all of these are really performances hogs!

   *In Drupal*: pay attention to deactivate modules like _devel_, _update_status_, _performance_ before to deploy in production.

4. Deactivate _cron_ automation managed by the application in automatic way (like Drupal's cron or Wordpress's wp-cron).  
Be sure you are running batches and asynchronous tasks during low-traffic hours, wherever possible. Remember to demand critical tasks or heavy tasks to external workers.

5. Deactivate any database logger, and switch logs to _syslog_

6. Check images size: manage size of every image applying standard dimension for each specific case. Pay a lot of attention if you have
numerous image dimension: often scripts that manages image resize/transforming consumes a lot of resources.

   *In Drupal*: Use opportune _image_styles_

7. Check retrieval process of external resources (feed, streams, etc.). I mean that we need to reply to questions like `How many time the application need to retrieve last Company's tweets?`, `How many time was spent to collect weather info to populate this badge?`, `It's normal that before to load the page we collect info related to the last match results?`

### Detection of application's bottleneck

Once we went through all the list above, your server will probably sigh in relief. This doesn't mean our work is done: we need to use right tools (especially if we lack specific references to slow page) to find the cause of th high server load. Before doing anything else we need to collect data about what's going under the hood, so we can improve in the right direction. Yes, I'm talking about [profiling](https://en.wikipedia.org/wiki/Profiling_(computer_programming)).

#### Getting insights by environmental monitoring

On Drupal 7, we can use the [Performance Logging](https://www.drupal.org/project/performance) module to profile time spent to generate pages, memory consumption, and how many queries fire during page load. We only need to navigate our site to populate the data table. On Drupal 8 the great _Web Profiler_ module, recently merged into [Devel](https://www.drupal.org/project/devel) project is the best option.

#### Environment side

The environment (local but also production), with the right tools can become our better friend to help us to find reasons of application's bottlenecks. There is a lot of profiler, but an excellent choice is [Blackfire](http://blackfire.io/): free, flexible and very light (his agent can be installed on the production servers with a really really thin overhead). The feature which makes me love Blackfire are his profiler result: a simple and clear diagram of entire code execution flow from the request response to the final output: all function calls will be analyzed and counted to produce a detailed report that contain a lot of useful data like function's time execution, memory consumption, etc. Finally all this data will be collected and the results will be showed to us related to the global status: a function that takes three seconds to produce an output, can be a lower problem related to another function that takes only 0.5 second but it's called ninety time.
Obviously, remember to puts on the mysql slow query log.

#### A practical profiling example

We have a simple Drupal 7 application that display 200 node's titles, but in the wrong way.

This is a Blackfire profiling output: [https://blackfire.io/profiles/f911c4ad-792b-4977-af51-d9e3b7649d24/graph](https://blackfire.io/profiles/f911c4ad-792b-4977-af51-d9e3b7649d24/graph)
We can clearly see a 'red branch' that indicates us where the most of time is spent to generate the page and we can see that the _node_load_ function was called 200 times after the call to _dsc_module_block_view_ , uhm IMHO it's better take a look to this function:

<pre>
function dsc_module_block_view($delta = '') {
  $block = array();
  switch ($delta) {
    case 'page_block':

    $node_titles = [];
    for ($i = 1; $i < 200; $i++) {
      $node = node_load($i);
      $node_titles[] = $node->title;
    }
    $content = '<ul>';
    foreach ($node_titles as $node_title) {
      $content .= '<li>;' . $node_title . '</li>';
    }
    $content .= '</ul>';
    $block['subject'] = t('My block');
    $block['content'] = array(
      '#type' => 'markup',
      '#markup' => $content,
      '#title' => t('Last 100 content'),
    );
    break;
  }
  return $block;
}
</pre>

With a simple refactoring we can improve the block generation:

<pre>
function dsc_module_block_view($delta = '') {
  $block = array();

  switch ($delta) {
    case 'page_block':

      $n_ids = [];

      for ($i = 1; $i > 200; $i++) {
        $n_ids[] = $i;
      }

      $results = db_select('node', 'n')
        ->fields('n', array('title'))
        ->condition('nid', $n_ids, 'IN')
        ->execute()
        ->fetchAll();
      $content = '<ul>';
      foreach ($results as $node_title) {
        $content .= '<li>' . $node_title->title . '</li>';
      }
      $content .= '</ul>';
      $block['subject'] = t('My block');
      $block['content'] = array(
        '#type' => 'markup',
        '#markup' => $content,
        '#title' => t('Last 100 content'),
      );
      break;
    }
    return $block;
  }
}
</pre>

And the Blackfire's verdict becomes [https://blackfire.io/profiles/b7243495-11d8-41fc-a374-e7bfe6e21ab7/graph](https://blackfire.io/profiles/b7243495-11d8-41fc-a374-e7bfe6e21ab7/graph): 1/3 of the time execution saved only with this refactoring.

Obviously this is a very basic example but it's not a remote possibility that these things happens.

### Some pro-tips to write code with an eye on performance

*While querying the database, ask only for the data you really need. Avoid `SELECT * FROM`, or
<pre>
db_select('table', 't')
->fields('t')
</pre>
that are the same things.
* Load entity in groups, not one by one: avoid `entity_load()` like `node_load()`, `taxonomy_term_load()`, etc. Replace it with `node_load_multiple()` or simple queries, if at all possible.
* Use - the - cache
  * Use views' caching and specially _views results_ and _rendered content_ caching
  * Use _drupal_static()_ to make data persist throughout the same request and the _Cache API_ to persist data between different requests over time.
* Demand heavy processes to external workers like [Gearman](http://gearman.org/) or use Drupal's _Batch API_

### Useful resources
* Repo of my DSC talk on Profiling examples: https://gitlab.sparkfabrik.com/vincenzo.dibiaggio/dsc-profiling
* Hints about query caching: https://www.percona.com/blog/2006/07/27/mysql-query-cache/
* Page rendering profiling: Yslow e Google Page Speed
* Browser: Google Developer Tools / Firebug - tab Network
* A good starting point on Views optimization: https://www.silviogutierrez.com/blog/optimizing-drupal-views-right-way/
* High Performance Drupal: http://shop.oreilly.com/product/0636920012269.do

