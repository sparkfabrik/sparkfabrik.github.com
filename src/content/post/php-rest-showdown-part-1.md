+++
date = "2017-03-04T14:47:30Z"
draft = false
title = "PHP REST tools showdown Series - Part 1: really RESTful APIs"
description = "A 10.000 feet overview of PHP tools and approaches to RESTful APIs"
tags        = [ "rest", "api", "services", "php", "drupal 8" ]
topics      = [ "REST APIs" ]
author = "Stick"
+++

## Introduction

This is the first of five posts in a series that want to tell you the story of my discovery journey through modern PHP tools to build a REST service layer.  

I have a sweet spot for REST and decoupled architectures, but working for a (mostly) Drupal company in the last (several) years, I had little occasion to put my head over the topic aside personal tinkering and small projects. Not to say that we didn't produced REST APIs for our customers, but a real decoupled project was hard to be found.

Then came Drupal 8, the first version of Drupal built from the ground-up to match enterprise use-cases: it brings many changes, embraces modern PHP to the core and is heavily oriented towards decoupled architectures. Actually, we can say **headless Drupal** is quite a buzzword these days. All good news, but hey... Drupal went finally PHP, which means that other modern PHP tools are finally within the reach of any *D8-savvy* developer.  
I dare to state that moving towards *SOLID* PHP, Drupal made himself less of a *queen bee*, diluting its ecosystem and exposing itself to direct confrontation with other PHP options.

This may seem counterintuitive, but I consider this a great strenght for Drupal in the first place: you don't have to decide between **making it "custom"** or **making it with Drupal**: it will be easy to carry your business logic in and out of Drupal if the need be. So with a healthy and open spirit of confrontation, let's dive into a journey among modern options to build REST APIs with PHP at the ides of March 2017.

## What makes an API really REST

The interweb is flooded with articles about what a good API is or is not. Just try to google for "rest api best practice".  
Is one more opinion on the topic worth a blog-post? I don't think so.

Nonetheless my indiscriminately inflated and voluminous ego drives me to barf my opinion hereunder for good measure; here is **my personal** take on what a good REST API is, in extreme synthesis. I'll add some information on what we have to take carefully, pitfalls etc.

I actually tackled into this topic yesterday, with a speech at Drupal Day 2017 in Rome - Italy, titled *REST in pieces* (with atrocious and ruinous pun). This series aims to dig deeper into the topic so I'll add a bit of information and (most important) a ton of lolcatz, sadly missing from my slides because time and blah blah.

****** UNACTEPTABLE LOLCAT *******



