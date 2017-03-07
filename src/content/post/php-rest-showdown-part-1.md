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

Nonetheless my indiscriminately inflated and voluminous ego forces me to barf my opinion hereunder for good measure; here is **my personal** take on what a good REST API is, in extreme synthesis. I'll add some information on what we have to take carefully, pitfalls etc.

I actually tackled into this topic yesterday, with a speech at Drupal Day 2017 in Rome - Italy, titled *REST in pieces* (an atrocious and ruinous pun). This series aims to dig deeper into the topic so I'll add a bit of information and (most important) a ton of lolcatz, sadly missing from my slides because time and blah blah.

![This is unacceptable!](/posts/20170304-rest-series/01-unacceptable-cat.png)

## Stick's 10 laws for a perfectly REST API

### 1. URI must be nouns, not verbs

Verbs are **already wired in HTTP** (`GET`, `POST`, etc) so it makes perfect sense, semantically speaking, to name your resources for what they are: resources.

Apples are resources (to feed a population), money are resources (to make charity or business), time is a resource (to invest in learning REST, lol).  
Navigate, press or play the guitar are not resources (whereas navigational skills, pressure and a guitar player can be - hey nouns!).

With the next point, why this is important will become clear: naming resources by nouns will grant you APIs **sensible semantics**.

--- TABLE WITH EXAMPLES ---

### 2. GET requests must never alter system/resource state

_Also known as_ **HTTP has verbs**.

This is where rule 1 above will begin to click. HTTP has verbs "hard-wired" in the protocol. You can `GET` a resource, `POST` it, `DELETE` it and so on. This basically means you can use HTTP syntax to write perfectly sensible expressions like `DELETE /books/123`, which even my granny can understand (this is good, leave useless complexity to bollywood screenwriters so they can make their mildly Asperger heros hack an alien spaceship via consumer wifi).

What if I ask you "Can you please get me a remove that stain from my shirt"? It would make little sense, specially compared to "Can you please remove that stain from my shirt?".

But there's more: you don't expect that collecting something will change its properties. Imagine a world where raising a cup of tea to your mouth change the content in olive oil. Or if buying a bulb means to automatically light it. Weird, huh?

Writing RESTful expressions boils down mostly on leveraging _by-design_ HTTP expressive power.

--- TABLE WITH EXAMPLES ---

### 3. Don't mix plurals and singulars

This is less of a rule and more of an advice. There is nothing inherently bad in pushing expressiveness towards natural language. Right? Meh...

I warn you against going too frenzy with expressiveness. It is important but can't come at the cost of consistency. In other words, while it makes perfect sense, in fluent English to `GET /books` (all of them) and `GET /book/123` (only that one), the `/books` &rarr; `/book` mapping creates an inconsistency among endpoints URIs.

I hear you mumbling "why this hurts, anyway?". First of all pluralization is not always straightforward, even in a language as consistent as English (if you don't think it is, try with Italian), so for example you can incur in the `person` &rarr; `people` case, which is a natural and fluent but hard to map inconsistency, compared to the books example.

Add to this that, despite good inflectors are available for all popular languages, automating URI composition on the client side is more painful if you have to deal with the singular/plural logic.

Last but not least, it's way easier to setup a consistent routing to your actions (think about your future you).

In the end, sticking with singular or plural is the best way to avoid complications that add little value. Choose one and go with it. My personal choice is for plural.

--- TABLE WITH EXAMPLES ---

### 4. Map relations by sub-resources

[Normal](https://en.wikipedia.org/wiki/Database_normalization) relationships intuitively boils down to a schematic form of **ownership**.  
We can say, for example that a user `has many` phone numbers, but `has one` profile. Invoices `has many` customer, while in turn customers `has many` invoices. And so on.

The best RESTful representation of those kind of relationships is achieved by **sub-resources**: `/books/123/reviews` is the resource endpoint for reviews related to book with ID `123`. Along this line, `/books/123/reviews/456` is a specific review among those book `123` got.

Redoundant? Yes, but also descriptive. And secure: since review `456` partains to book `123`, trying to `GET /books/098/reviews/456` should fail with a `404 Not found` error (see below for more status-codes and love).

Should we also redound the endpoints to provide different access routes? Like, following the example above, should we have a `reviews/456/books` resource so that I can go backward from reviews to books?  
Well, this really depends on your domain: if you know you need a list of reviews, no matter the book they are related to, or (to add a dimension to this depiction) if you may need reviews by author, like `/users/987/reviews`, then why not? I would go further and say that you can go fancy with filters on a `/reviews` resource endpoint (see below for filters galore).

Just avoid proliferating your endpoint just for the sake of having them at hand. Design is the most important step in API development and declaring resources informs by  itself about the hierarchy, relations and logic the clients are expected to follow.

--- TABLE WITH EXAMPLES ---

### 5. Negotiate format in HTTP headers

This is a rule many frameworks allows to break easily, but trust me: there are headers for content negotiation and they work well and consistently.  
Request headers allow the server and the client to specify which kind of data you are passing and expecting in the request body. Are the client sending XML with its `POST`? Is the server supposed to respond with a JSON payload to that `GET`?

Two nice headers are available for this and here they are in all their splendour:

> `Content-type`

Specifies what's inside the request body.

> `Accept`

Specifies which format the server is supposed to pack the response so that it doesn't stink.

Those headers accept mime-types, like `Content-type: application/json` or `Accept: text/xml`. Compare this to other means like slapping a fake file extension at the end of the resource URI:

> `GET /books/123.json`

to inform the server we are expecting a JSON payload... way more expressive and powerful if you want, for example, a `JSON-LD` HATEOAS payload, or other forms of RDF structure:

> `Accept: application/json+ld`
> `Accept: application/rdf+json

Try to pollute this in a fake extension, a parameter or (may God forgive you) as part of the request body. The mere effort is simply nonsense!

--- TABLE WITH EXAMPLES ---

### 6. Leverage powerful HTTP caching

This paragraph would deserve a full book _per se_. The topic is really huge and I don't even have the experience to compete in clarity and 
