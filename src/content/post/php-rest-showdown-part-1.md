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

| Right | Wrong |
|:-:|:-:|
| `/cars` | `/getAllCars` |
| `/users` | `/userRemove` |
| `/books/{id}` | `/books/{id}/remove` |


### 2. GET requests must never alter system/resource state

_Also known as_ **HTTP has verbs**.

This is where rule 1 above begins to click. HTTP has verbs "hard-wired" in the protocol. You can `GET` a resource, `POST` it, `DELETE` it and so on. This basically means you can use HTTP syntax to write perfectly sensible expressions like `DELETE /books/123`, which even my granny can understand (this is good, leave useless complexity to bollywood screenwriters so they can make their mildly Asperger heros hack an alien spaceship via consumer wifi).

What if I ask you "Can you please get me a remove that stain from my shirt"? It would make little sense, specially compared to "Can you please remove that stain from my shirt?".

But there's more: you don't expect that collecting something will change its properties. Imagine a world where raising a cup of tea to your mouth change the content in olive oil. Or if buying a bulb means to automatically light it. Weird, huh?

Writing RESTful expressions boils down mostly on leveraging _by-design_ HTTP expressive power.

![GET ME OUT!](/posts/20170304-rest-series/02-invariantstate-cat.png)

| Right | Wrong |
|:-:|:-:|
| `POST /cars` | `GET /addCar` |
| `DELETE /users/{uid}` | `GET /userRemove` |
| `PUT /books/{id}` | `GET /books/{id}/update` |

### 3. Don't mix plurals and singulars

This is less of a rule and more of an advice. There is nothing inherently bad in pushing expressiveness towards natural language. Right? Meh...

I warn you against going too frenzy with expressiveness. It is important but can't come at the cost of consistency. In other words, while it makes perfect sense, in fluent English to `GET /books` (all of them) and `GET /book/123` (only that one), the `/books` &rarr; `/book` mapping creates an inconsistency among endpoints URIs.

I hear you mumbling "why this hurts, anyway?". First of all pluralization is not always straightforward, even in a language as consistent as English (if you don't think it is, try with Italian), so for example you can incur in the `person` &rarr; `people` case, which is a natural and fluent but hard to map inconsistency, compared to the books example.

In addition, despite good inflectors are available for all popular languages, automating URI composition on the client side is more painful if you have to deal with the singular/plural/collective-nouns logic.

Last but not least, it's way easier to setup a consistent routing to your actions (think about your future you).

In the end, sticking with singular or plural is the best way to avoid complications that add little value. Choose one and go with it. My personal choice is for plural.

| Right | Wrong |
|---|---|
| `GET /users` | `GET /users` (_Right but inconsistent with the following_)
| `DELETE /users/{uid}` | `DELETE /user/{uid}` |
| `GET /users/{uid}/reviews` | `GET /user/{uid}/reviews` (_This really sucks..._)| 
| `POST /users/{uid}/reviews` | `POST /user/{uid}/review` |
| `PUT /users/{uid}/reviews/{rid}` | `POST /user/{uid}/review/{rid}` |

### 4. Map relations by sub-resources

[Normal](https://en.wikipedia.org/wiki/Database_normalization) relationships intuitively boils down to a schematic form of **ownership**.  
We can say, for example that a user `has many` phone numbers, but `has one` profile. Invoices `has many` customer, while in turn customers `has many` invoices. And so on.

The best RESTful representation of those kind of relationships is achieved by **sub-resources**: `/books/123/reviews` is the resource endpoint for reviews related to book with ID `123`. Along this line, `/books/123/reviews/456` is a specific review among those book `123` got.

Redoundant? Yes, but also descriptive. And secure: since review `456` partains to book `123`, trying to `GET /books/098/reviews/456` should fail with a `404 Not found` error (see below for more status-codes and love).

Should we also redound the endpoints to provide different access routes? Like, following the example above, should we have a `reviews/456/books` resource so that I can go backward from reviews to books?  
Well, this really depends on your domain: if you know you need a list of reviews, no matter the book they are related to, or (to add a dimension to this depiction) if you may need reviews by author, like `/users/987/reviews`, then why not? I would go further and say that you can go fancy with filters on a `/reviews` resource endpoint (see below for filters galore).

Just avoid proliferating your endpoint just for the sake of having them at hand. Design is the most important step in API development and declaring resources informs by  itself about the hierarchy, relations and logic the clients are expected to follow.

![Sub cat behaving hierarchically](/posts/20170304-rest-series/04-subres-cat.png)

| Right | Wrong |
|:-:|:-:|
| `GET /users/{uid}/reviews` | `GET /reviews?byUserId={uid}` |
| `PUT /users/{uid}/reviews/{rid}` | `PUT /userReviews/{rid}` |

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
> `Accept: application/rdf+json`

Try to pollute this in a fake extension, a parameter or (may God forgive) as part of the request body. The mere effort is simply nonsense!

| Right | Wrong |
|---|---|
| `Content-Type : application/json` | `PUT /reviews.json` |
| `Accept : text/xml` | `GET /reviews?format=xml` |

### 6. Leverage powerful HTTP caching

This paragraph would deserve a full book _per se_. The topic is really huge and I don't even have the experience to compete in clarity and completeness with other authors.  
Still I feel that HTTP caching features are often overlooked by many, mostly when it comes to REST API design.

To support my statement I often take as an example the fact that (in my experience) far too often the `etag` header goes totally unconsidered during API design, though it is a brillant solution to content-based cache invalidation.

Google has a great article on [HTTP caching](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching) on the Developer Network.
Just remember these three things:

* The problem with caching is its *invalidation strategy*; pretty obvious but it's often very tricky to come up with a good one
* HTTP allows for *content-based* and *time-based* invalidation, which is a real boon since *you can trade off performances and data reliability*
* Being based on response headers, HTTP caching allows *per-resource strategies*, which means you can carry out the aformentioned trade-offs depending on the nature of the data

Not bad of a transfer protocol, uh? :)

![Copy cat :D](/posts/20170304-rest-series/06-cachecopy-cat.png)


### 7. Allow for collections filtering, sorting and paging

**This is query parameters time!**

After having disparaged query parameters in almost all former examples, here they come to save our day. Did you know humans can easily find an element in up to a dozen, with little to none [cognitive load](https://en.wikipedia.org/wiki/Cognitive_load)? That's why good interfaces allow for filtering result-sets (and why it is so important to rack high on search engines, just to say).

Narrowing and ordering sets is so pervasive in computing and information technology that we tend to take it for granted. Client applications (even on a server-to-server basis) will often require a narrow set of results, specific to some criteria. This is important to avoid sending heavy payloads that the client, and leave all the storage technology behind the service layer do the job it is probably most qualified.

Query parameters can express sorting and filtering criteria, as well as paging long result sets.  
It is important, in my opinion, to point out a subtle difference between *filtering results* and *identifying a resource*. Take those two different URIs:

1. `/users/1`
1. `/users?uid=1`

both seems legit ways to get - say - the profile of the user whose id is `1`. But they is a difference: the first is a URI (_universal resource identifier_, remarkably) for a user profile, the other is not. Actually the second URI identifies a collection of user profiles which incidentally (given the restricting filter applied) is composed by a single item.

I even expect the payload to differ substantially. In case 1 it should be something like:

```javascript
{
   'uid' : 1,
   'name' : 'John Doe',
   ...
}
```

while in the second case I expect it to be

```javascript
[
   {
      'uid' : 1,
      'name' : 'John Doe',
      ...
   }
]
```

that is in fact an array with a single item.  
This *matters*! If you need to identify a specific resource to perform state-changing operations on it, you should really have a URI for it.

This is also true at some extent for collections of related items. Take this as an example:

1. `/users/1/books`
1. `/books?owner_id=1`

This is trickier and it really depends on what you need in the domain of your application. Is the collection of books owned by a specific user` a resource by itself? Or in better words, are book collections resources for the users of your system? If so, being a resource, the user's book collection deserves a universal identifier. If not, go with a filtered collection.  
Mind that nothing stops you to have both, but don't just throw them in for good measure... think about your domain, how entities are related and what kind of operations you want to perform on a resource.

![Copy cat :D](/posts/20170304-rest-series/07-mindurfilters-cat.png)

OK, back to our filters, sorting and paging. Query parameters are pretty flexible and you can go fancy with expressiveness. Here is some example of how you can enpower your clients:

| Right | Wrong |
|---|---|
| `GET /users?sort=-age,+name` | `GET /users?sortAsc=name&sortDesc=age` |
| `GET /users/{uid}/reviews?rate>=3&published=1` | `GET /userReviews?uid={uid}&rate>=3` |
| `GET /books?format=[epub,mobi]` | `GET /books?format=epub&format=mobi` |


To close this paragraph with one more digression, I'm not a fan of field-selection, that is allowing the client to list the fields it wants to receive for a resource representations. It surely can come in handy, but mind that APIs are not a trendy way to allow a client to access a database. A service layer is, as the name implies, something that provide a service: it often holds business logic behind its endpoints.  
There are cases where your API is simply a secure and decoupled persistence layer, while your client holds all of the business logic. Good examples of this are some dedicated iOS or Android apps, which doesn't even have a web counterpart. As long as clients performing the same functions over and over proliferate on different channels (web, SmartTVs, mobile OSes, etc), you service layer will become a RESTful representation of your application model.

Field selection in filters, not bad _per se_, smells a bit: think twice if you are not envisioning your API as a mere data-access layer.

### 8. Version your API

This is really as simple as it seems, but it's a **golden rule**. Your clients should **always** have the possibility to reach a specific production version of your API, on a specific URL.

If you work mainly with web applications you can wonder why this matters. After all if you introduce breaking changes in your API but deploy a matching client that supports those changes, there is not problem, right? Tackling into mobile apps should make you change your mind: you can't just push updates to customers' phones (er, [almost](http://microsoft.github.io/code-push/)). If your clients are outside of your control then, the game is almost over.

That's why it is so important to deploy your API to a URL which specify your API version. But pay attention, we are not talking about exposing your codebase versioning: you can deploy the `1.14.05` codebase version, which is exposing the version `v1` of your API. As long as the API does not introduce breaking changes (that is to say, if you can query each endpoint, receiving the same response format from them), you must consider it the same version.

In fact there are cases when a specific version of your codebase delivers fixes or changes to more than a version of your API. API versioning refers to format, not development iterations.  
Of course, the major version of your codebase can be the same as the format version of your API. This makes perfect sense and help keeping things under control, so `codebase 1.x` &rarr; `API v1`, and `codebase 2.x` &rarr; `API v2`.

Where to place your version? My preference is in the domain, like `https://v1.api.stick.says`, but even a subtree like `https://api.stick.says/v1` (which is supported out of the box by most frameworks) does the job.

It goes without saying that the point here is not to keep each and every version of your API online indefinitely! You can (and will) surely deprecate old versions soon or late, but you can do this on a public schedule, communicating the variations and version EOL, and collecting information about the degree of adoption of new versions by the clients (hint: use logs to collect usage statistics of your endpoints!).

| Right | Wrong |
|---|---|
| `GET /v1/users?sort=-age,+name` | `GET /users?format=old` |
| `POST api.v2.stick.says/users` | `POST /users?format=2017` |

### 9. Return meaningful status codes

*HTTP has response status codes!* This is not a breaking news, it has since its inception and we are all well aware of the (in)famous `404 Not found` that pops here and there in our browsers.  
Still, 20+ years from the devision of HTTP, I still happen to see established professionals going with `200 OK` as the unique response code.

![I sense evil](/posts/20170304-rest-series/09-senseevil-cat.png)

If you are about to say one of those

> _I'm placing my error status in the payload, so no need to use HTTP codes_

> _It is really not important, just return 200 OK so that client lib won't complain_

> _Status WAT?_

Please, go back enveloping SOAP and leave me alone wondering what went wrong with the world! :D

Jokes apart, you'll probably think by now that my sweet spot for HTTP may be a little too _sweeeet_ (creepy indeed), but hey: Sir Tim Berners Lee created one of the most complete and expressive transfer protocols in the late 80s. I'm pretty sure most of my readers were shaking their rattles at the time. So really, don't ignore the fact that the fundamental protocol that ended up killin all former nerd/net technologies and cultures were designed to do **one thing well**. And heck, it does! :)

Returning meaningful status codes means your client (the machine, not the human) can understand what happened to the request without analyzing the response payload, which in turn helps your client (the human, not the machine) to get additional information, useful to a sentient being.

I'll list here some HTTP status codes trivia which may or may not be common knowledge for you. If you learn something new, my advice is to dig deeper into HTML protocol and learn what it can already do for us.

* **HTTP status codes are numerals with an optional description**: The format of response status codes is alwas a 3-digits number like `201`, `302`, `404` or `401`. Mnemonic descriptions are added so that us meatbags can remember what they mean: `401 Unauthorized`, `302 Permanent redirect` or `200 OK`

* **HTTP status codes are categorized by the most significant digit**: Being very unlikely for an application to have hundreds of different statuses of the same category (if you are in succh a situation you may double check your assumptions... it smells a bit), the _hundreds_ are used to represent status categories. For a complete reference see the related part of [RFC 2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html). For a shorter version and some notable insight, see [my table in the end notes](#httpstatuses).

* **There is space for custom error code in each category**: And, as long as you document them for your client, you are encouraged to use them! You may not know this, but there is an actual [`418 I'm a teapot`](https://tools.ietf.org/html/rfc2324) implementation case registered in history. And [Symfony framework natively supports it](https://github.com/symfony/http-foundation/blob/master/Response.php#L61) :). So really, don't be shy and make good use of HTTP flexibility to inform your client about what the heck happened to their request.

* **You can haz cats**: Yes, there are things like [HTTP Status Cats API](https://http.cat/) or, if you feel more like you want puppies, [HTTP Status Dogs](https://httpstatusdogs.com/). I can't state how important is you make use of this bleeding edge technologies! **World can be saved, after all...**

![Toy resource not found](/posts/20170304-rest-series/09-notfound-cat.jpg)


#### Good

```http
401 UNAUTHORIZED

{
  "errors": [
     {
         "user_msg": "You shall nooot paaass!!!",
         "internal_msg": "Balrogs are not welcome",
         "code": 666,
         “info": "http://stick.says/docs/v1/errors/666"
     }
   ]
}

```

#### Bad

```http
200 OK

{
  “status” : “error”,
  "user_msg": "You shall nooot paaass!!!",
  "internal_msg": "Balrogs are not welcome",
  "code": 666,
  “info": "http://stick.says/docs/v1/errors/666"
}
```

### 10. Use modern authorization methods

If you live in a well-off countryside area like me, you may have retained the old habit of putting your keys under the doormat.  
Actually I am not! Times changes and I am not that akin to suffer thievery. Securing your resources is important, but most important yet, is to know who can access which one.

Bear with the analogy for a while, please. My friends may come visit, they just have to ring the bell and say their name. In this they are able to access my house while I am in.
But this doesn't mean I give them free access to my wardrobe or family bank account. Those are resources that may be accessed only by high privileged people in my family.

Now, what if my wife wants to access the home-banking and performs transitions? Sure she can, so I can let her use my token (it's actually the opposite, lol). Giving her my token, I allow her to act _on my behalf_ on the `bank account` resource. Most important, this can happen outside of my control, as long as the authorization is valid.

So it is possible for a set of agents to access the house via **authentication** (identifying them at the door) and to access some resource under my direct or indirect supervision, for their staying.
Other specific agents may instead manage private resources by gaining an **authorization** (asking me the token). The nuance that tells _authentication_ from _authorization_ is subtle but can be clearly stated in that:

* *Authentication is a necessary condition to gain authorization*: I must know who you are before you can act on my behalf. It is not sufficient to gain control of my resources though.
* *Authorization has one or more scopes*: Once you are authenticated (I know who you are), I can grant you access to a set of resources you can use on my behalf. This access can be temporary and conditioned to a specific logic. Let's call those set of resources `scopes`. It is clear that access to different scopes like _See bank account balance_, _Trigger money transfers_, _Use TV_, _Access wardrobe_, etc may be granted to different people over time.
* *Authorization can be revoked*: Revoking authentication means losing memory of the identity of someone, since authentication boils down to identifying someone. Denying access to a resource instead means you are revoking an authorization to someone you can identify.

![Please, move on...](/posts/20170304-rest-series/10-nomoremetaphors-cat.png)

Uoookkey, enough metaphors; in the context of our service layer we can say the user can authenticate by providing credentials and be authorized to access resources by a permissions framework.

Now, HTTP is a stateless protocol so if you want to have some RESTpect (sorry), you'd better **avoid relying on sessions** to authorize the client.  
Use modern stateless authorization framework instead.

The two most reknown example here are [Oauth2](https://oauth.net/2/) and [JSON Web Tokens](https://jwt.io/) (aka JWT).
Both are standards (actually Oauth2 is not, it [failed to be standardized](https://hueniverse.com/2012/07/26/oauth-2-0-and-the-road-to-hell/) and is now considered a framework) to describe how a client may act on behalf of an authenticated user in a statless world.

Digging into the two would require a series of posts (or entire books) but in the scope of this article it suffice to say that:

* **Oauth2 is a great way to allow other server applications to access your resources on behalf of a user**  
  Social are the most common example of this: when you take one of those silly tests like "What mutant animal from the world of Sglorbz am I?" on Facebook, you are asked to grant access to your profile data (and God knows what else!) to (say) "Silly online quizzes Inc.", which is a third party application that knows nothing about you but wants to create a profile and post things on your wall regarding your assumed Sglorbziness.  
  To achieve this the app asks you (the resources owner) to unlock more or less permanent access to your profile and the ability to post on your wall (yes, these are _scopes_). The silly tests app gains a token on authorization, which can be used to act on that scopes, even when your browser is closed and you are asleep. Actually the server's app may impersonate you within the boundaries of the granted scopes.  
  You can do this too: I mean you can both allow other apps to act on behalf of your users (that is you expose an Oauth2 Server) or you may hook into another REST API gaining access to its resources (you are acting like an Oauth2 client). Often you end up doing both, and that's the web, and it's great!
* **JWT is the right way to allow a rich client web application or a native application to act as a user interface**  
  Modern single page application written in frameworks like Angular.js or React holds part of the application logic in the client. You may be accustomed with the concept of server session, that is the server holding a state behing an HTTP request/response curtain. JTW allows for a real stateless connection: again, a token is exchanged with each request to match the client's authorizations as well as the user's authentication. JWT tokens generally have a short life and can hold actual information in a smart and secure way.  
  A modern API which goal is to serve client application should really rely on JWT to handle permissions!

## Final thoughts

Here you are my 10 golden rules for a perfectly REST API! **Hurray!**

Or not? I can here some of you:

> _But wait... where is HATEOAS?! And you old fart forgot to mention RDF also!!?!1!1!!cos(0)_

OK, let's make clear that despite I've kept an overconfident tone, which was hopefully just hilarious, **the above doesn't want to be a universal source of truth about what makes a good REST API**. It is just what I learned over the years for you to put to good use.

That said, I have mixed feelings about [HATEOAS](http://en.wikipedia.org/wiki/HATEOAS) and [RDF](http://en.wikipedia.org/wiki/Resource_Description_Framework)-related stuff (JSON-LD etc, for the record).  
My guts say - and I would be happy to prove them wrong - that to date we have a lot of stuff that seem to perfectly match REST in describing resources semantics, but it's unclear how the client should actually behave with those data. Since yep, hypermedia navigation is all about behavior.

Take HATEOAS for example: nice to receive a list of available links (the catalogue of legit state transitions, to be a bit pedantic) in the payload, now what?  
Without a clear behavioral framework to apply, client side, it is left to the developer to understand what to do with the information... at that point it is better not to do any server-side assumption and provide clear documentation so the client developer can forge URIs by himself, handling unavailable transitions at application level.

Almost the same with RDF. Great meaningful semantic but then when it comes to hypermedia-ize it all, we need stuff like [RESTdesc](http://restdesc.org/) or [Hydra](http://www.markus-lanthaler.com/hydra/) (which is in turn an RDF application by itself, to make things worse :D) to describe how the client is supposed to behave to get along. So what is the client logic actually supposed to do in the first place?

To finish, a mention about content enrichment: I'd leave it to business middleware. It's not just a matter of hype like _woohoo, microservices are all the rage, so never create a monolith anymore (but do middleware or clients will knock your door down by night)_.  
It's just that it's unhealthy to have native modality to perform content enrichment in the hope that your data-level service layer will hit all possible clients use cases. That's what specialized middlewares are for, put them to good use!

## Conclusions

To wrap it up, **don't stop here!** There are a lot of great books out there on how to design great REST APIs, go read them and better yet, get your hands dirty!

Reach for your [apiary](https://apiary.io/) account or start a [Swagger](http://swagger.io/) project and grind your teeth.

Just remember a great service layer starts from its design, so don't rush installing the last new sensational tool: **your brainwork comes first**.

See you soon with the next article of the series: **Drupal 8 REST features breakdown**.

## Additional resources

### Further readings

* [Build APIs you won't hate](https://apisyouwonthate.com/) - Book by [Phil Sturgen](https://philsturgeon.uk)
* [REST API Design rulebook](http://shop.oreilly.com/product/0636920021575.do) - Book by [Mark Masse](http://www.oreilly.com/pub/au/4998)

### <a name="httpstatuses"></a>Personal blurb on HTTP status codes

|Range|Category|Usage|
|---|---|---|
| 1xx | Informational | Intended for when you have to respond with an information about the management of the request, like `100 Continue` (which I think I spotted only in proxies traffic) or `101 Switching protocols` (which informs the client that the server is OK in changing the application protocols). |
| 2xx | Successfull | Inform the client that _Yay! Allrite bro!_ The infamous `200 OK` which is a laconic way to say _the request has been understood and here is the content you required_ is the most known specimen, but `201 Created` (after a succesfull `POST`) or `204 No content` (when you ask for a resource which *is there* but has no content, like an empty collection) are good examples to understand what those codes are there for.|
| 3xx | Redirection | Handle all situations where the client is redirected to another source of information or URL. Local cache is a source if information, thus the `304 Not modified` makes perfect sense in this family. Renowned examples are `301 Moved permanently` and `302 Found`, but also `305 Use proxy` showcases how useful those code are. |
| 4xx | Client Error | Used in every case where the request can't be processed but it seems the client is to blame. The most widely known is the `404 Not found` upon everybody in the world stumbled at least once. Note that this differs from `204 No content` in that querying a collection with no items in it (for example due to heavy filtering) doesn't mean the collection isn't there. Querying for a URI which does not represent any resouce (hence is not routed/handled by the system) is actually a client error! But learn more and use stuff like `401 Unauthorized`, that is the client didn't provide necessary credentials to access a protected resource, or `405 Method not allowed` for when the client tries to use an HTTP method/verb on a resource that does not support it (`PUT` or `PATCH` a collection for example?). |
| 5xx | Server Error | Those are for when the request can't be processed but the server knows the problem lies in its request processing, not the request itself. The most spotted error in this category is the pretty uninfomative `500 Internal server error`, which map one-to-one with the `Uknown error` or `Unexpected error` some can remember from Windows 9x era. If the server has any clue on what happened it may be more helpful, returning stuff like `501 Not implemented` or `505 HTTP version not supported` (try to find one of those old farts, if you can!). Just mind that *it is really unlikely you will have to manage 5xx status codes at application level*, so use them only if you really know what you are doing! |
