# Sparkfabrik's tech blog

## Installation

### Docker

You can run everything needed to start developing with hugo, just running
`docker-compose up -d`, just make sure to have `dnsdock` container up and running or
point `tech.sparkfabrik.loc:1313` or `localhost:1313`.

The `hugo` container expose a fixed port 80 to the docker host.

#### Gotchas on OSX/Windows

As on OSX/Windows docker uses vboxfs/nfs which does not support any kind of inotify-like
notifications events, you can't rely on the really useful livereload while editing the blog
using a GUI editor.
To manual rebuild the pages run `make build-loc`

### Native

#### OSX

Install hugo with brew: `brew install hugo`

Then `cd src && hugo server --buildDrafts --theme spark --baseUrl=http://localhost:1313`
or just execute `scripts/run-local-server.sh`

### Windows

<troll>
Are you really using Windows ?! :D
</troll>

Download latest release here: https://github.com/spf13/hugo/releases/download/v0.15/hugo_0.15_windows_amd64.zip

Then `cd src && hugo server --buildDrafts --theme spark --baseUrl=http://localhost:1313`

## Usage

Official documentation: https://gohugo.io/overview/introduction/

Source code structure:

```
src
├── archetypes
├── config.toml              <-- hugo global configurations
├── content                  <-- contents
│   ├── archive.md           <-- achive page (route `/archive`)
│   ├── pages
│   │   ├── about.md         <-- page about (route `/page/about`)
│   │   └── team.md          <-- page team (route `/page/team`)
│   └── post
│       └── hello-world.md   <-- blog post (route `/post/hello-world`)
├── data
├── layouts
│   └── archive              <-- custom page layouts
├── static                   <-- static assets
│   ├── css
│   └── img
└── themes
    └── spark
    ```

The following steps to contribute with a post:

# Clone the repo
# Create a branch start from the last `dev`, for example `post/docker-starterkit`
# Save the file to `src/content/page/docker-starterkit.md` commit and push
# Open a new MR from `post/docker-starterkit` => `dev` and ask your colleagues for a review
# Check the travis.ci build, if you have enough :+1: and travis.ci, just merge the page to auto deploy
your post





