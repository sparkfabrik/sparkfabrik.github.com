+++
date = "2016-06-14T11:02:30Z"
draft = false
title = "Wait a minute, Doc"
description = "How we leveraged Raneto and Docker to tame projects documentation"
tags        = [ "documentation", "raneto", "docker", "markdown"  ]
topics      = [ "Documentation", "FOSS", "Docker" ]
author = "Stick"
+++

Only the brave can be web developers today.
I really think if you are a web developer, nothing can scare the crap out of you! Nothing but writing documentation for your code...

Let's face it, we **hate** writing doc! In fact developers came up with a lot of clever tools to automatize code documentation, and they work well and reliably to date.
But there are cases where you have to jot down a guide to first build, or a reference page with best practices. Odds are good you end up using a project wiki, or if you are less fortunate you are juggling through a bunch of never-to-be-found Google Documents.

Well, look no further: here we have a recipe to soothe your pain!  
It may not be a panacea but surely it will streamline the process of documentation maintenance and availability.

Say welcome to Raneto!

<!-- more -->

### Hey doc, this is heavy!

![This is heavy](/posts/wamd-thisisheavy-meme.jpg)

So let's start listing our pains with project documentation:

**1. Manage documentation requires a context switch**

When you live in a tmux-powered kickin-ass hyper-hipster hyphens-overloaded console environment the more annoying thing to do is switch to a browser, navigate to your tracker's wiki, make your way to the right page and edit the stuff. It is discomfortable and a great excuse for procrastination. 
This is in my opition the first reason why documentation goes obsolete from day 1.

Add problems like write permissions on knowledge-base tools, another approval workflow to manage, possible policies-hell, etc. and you'll flip your table at the sole idea!

Surely, having a more straighforward path from your working environment to your documentation helps you keep it up to date.

**2. Documentation is hard to evolve with your project**

When your team is involved on a medium-to-long term project, you really need to keep track of changes. But changes don't always happen in line. 
Wild branching, forking and bisecting happens in your codebase as experimental feature get thrown in and out, or the codebase is updated to work on the next _\<your technology of choice\>_ release. This means documentation should ideally follow along with your codebase.

For example, a three-years long project of ours was recently moved from an "old fashioned" PHP5 based environment to a shiny new docker-based, PHP7 one. The process took weeks and almost totally changed the way we perform builds, not to mention how local development environment work.
Maintaining two pages on a wiki, with almost the same title, and drop a note somewhere to explain which page to read is ugly as a single-headed monkey. It introduces throw-away information, generates confusion and is hard to read for both experienced teammates and newcomers.

This leads to the next point.

**3. When documentation is hard to find or unreliable, people stop reaching for it**

Natural tendency towards the path of least resistence makes people want to ~~stre~~ ping one another on Slack instead of searching for information in the docs, simply because it is perceived as quicker, easier and (this is bad) more reliable.
This in turn makes some people the SPOF for important information, which is never persisted anywhere and when it does, it's left alone and quickly goes out of date.

> No good!

So we had a bunch of problems to solve:

* Streamline the process of writing and maintaining documentation by devs point of view
* Make documentation accessible, reliable and relevant to the project state
* Allow anybody to contribute to documentation
* Avoid *moar policies* for contributions
* Be cool (it's always important to be cool if you want to write an article on what you are doing) (or if you want to play metal :D )

Now what?


### Back to the future

![I got gigawatts](/posts/wamd-gigawatts-meme.jpg)

And it happened. 
A customer asked our CTO to write guidelines on how to ensure maximum performance on the project before committing new contributions. 

Now, if you ask a developer to write documentation you are making her a major disservice, but if you ask a CTO you are probably causing you permanent damage! 
Paolo decided to avoid physical confrontation and went the simple way: he dropped a markdown file with instructions in the project repository, in a folder called "Documentation".

He didn't event thought about opening the wiki (which was covered in cobwebs anyway). He did what was natural and obvious to him. And we ended up with a file we could read, nicely formatted, on our Gitlab instance. 

> Hey, not bad!

I was already in search for an easy to maintain knowledge-base platform and I thought in 2016, when static site generator are all-the-rage and everybody drools on going down-to-metal, maybe someone would have had addressed the problem, building a simple markdown-powered knowledge based generator.

And guess what?! [Someone](https://gilbert.pellegrom.me) [did](https://github.com/gilbitron/Ranet).

A bit of research and I stumbled on [Raneto](http://raneto.com), a node-based, markdown-powered knowledge base site generator. Not static, but still. :)

Raneto actually has a lot of selling points that made me fall in love:

* It's easy to install and use.
* It has no database, or if you prefer, your flat markdown files are it's database.
* It is fast and pretty lightweight, with the whole stack sucking around 65MB of RAM.
* It renders to a pleasant default template, which can be themed with [Mustache](https://mustache.github.io), highlights your code, support GitHub-flavored MarkDown and is also responsive.
* It allows you to perform full text search in the doc.
* Its index and documentation navigation are directory&slug-driven: you don't have to build a menu, just arrange your files in folders `to/reflect/doc-sections` and name dirs and files `using-a-slug-to-make-them-readable` and you'll end up with human readable version of menu links and titles.
* The whole doc reads in 5 minutes. From a smartphone. On a crowded train. I did.

Yay! Now our CTO documentation looks really cute, with unicorns, rainbows and all!

> Going down-to-metal leapfrogged us to the future! Yay!

It's like flying-skates cool! Almost...


### Great Dock!!!

OK, we got a great service to hadle our CTO-proof documentation.
But no ~~hipst~~ modern CTO would ever accept another dependency in his stack.

The idea here is to have a folder in your project repository to hold all the relevant documentation so that:

* Anybody can contribute with the same policies they use for code (do you review MRs? Use git-flow? Commit directly on master? No, seriously... don't do this, even at home!)
* Different branches or forks can have different version of the documentation
* Navigating the source code from Gitlab/GitHub/Bitbucket/Whatever allows you to read the documentation files anyway (a nice addition)

We miss a way to make Raneto available in a snap! 
The solution is obviously to dockerize the whole thing out. And manage the container with docker-compose for good measure, of course!

So [I prepared a container](https://hub.docker.com/r/sparkfabrik/docker-node-raneto) which mounts the local folder in a volume and expose the content via Raneto, on port 80 for easier access!
The documentation is pretty straightforward (eh! ^\_^') but if you want to play with it right now, follow these steps:

**Create a folder structure like this:**

```
mkdir -p documentation/docs
mkdir -p documentation/files
```

The first directory will hold your markdown files. The second one will be mounted to the public asset folder, so you can have images or attachments in your documentation.

**Write some example doc**

You can drop the following in `documentation/docs/up-to-88.md`:

```
This is a silly example page with **markdown** syntax!

_And here is an even more silly meme_
![88mph](files/silly-meme.png)
``` 

then put one of the silly memes on this page in `files` directory (of course name it `silly-meme.png`)

Done?

**Launch Raneto in its container**

Run 

```
docker run -p 80:80 -v </full/path/to/your/content>:/srv/raneto/content -d sparkfabrik/raneto
```

and enjoy your documentation at http://localhost:80

> Yes! It is THAT simple! :)


![Whew... this was fast](/posts/wamd-wasfast-meme.jpg)


### Hey, you! Get your damn hands off it! 

But why, oh why would you want to launch a container by hand when you can do it with [docker-compose](https://docs.docker.com/compose)? 
Actually there are a lot of potential reason, but leave me my drama and follow along: to make your documentation quickly accessible in your project the best thing to do is to install [dnsdock](https://github.com/tonistiigi/dnsdock) ([this guide](http://blog.brunopaz.net/easy-discover-your-docker-containers-with-dnsdock/) may come in handy) and register a URL for your project documentation.

You can either create a new `docker-compose.yml` file in your project root with the following content, or add these lines to the one you have in place.

```
documentation:
  image: sparkfabrik/docker-node-raneto:0.9.0
  environment:
    - DNSDOCK_ALIAS=docs.whatever.localdomain.loc
  volumes:
    - ./documentation/docs:/srv/raneto/content
    - ./documentation/files:/srv/raneto/themes/default/public/files
```

Once done, and given your file is in the same directory than your `documentation` folder, just run:

```
docker-compose up -d
```

to enjoy your documentation at http://docs.whatever.localdomain.loc


### What-what the hell is a gigawatt? 

Want to go the easy way?
You can test the all of the above cloning this repo: https://github.com/stickgrinder/spark-docker-raneto-demo

![You did almost nothing...](/posts/wamd-calculations-meme.jpg)

**NOTE**: Mind that you have to have dnsdock in place *OR* create an entry in the hostfile to resolve `docs.demo.sparkfabrik.loc` to the IP of the container started by docker-compose.

### Give me a milk... Chocolate!

If you now feel like a real documentation badass, pat yourself a shoulder: **you are!**

This simple container still has a long way to go: for example public assets would be better served in a folder outside the default theme. Even better, it can support custom theme in the project folder. 
But you surely have more clever ideas so please, find the container definition [here](https://github.com/sparkfabrik/docker-node-raneto), fork it and adapt it to your needs and workflow! 

And don't forget to send PRs in! :)

Happy doc(k)ing everybody!
