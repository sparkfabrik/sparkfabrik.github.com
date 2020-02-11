BASE_URL="https://sparkfabrik.github.io"
DEPLOY_DIR=output
DEPLOY_BRANCH=master
DEPLOY_REPO=https://$(GITHUB_TOKEN)@github.com/sparkfabrik/sparkfabrik.github.com.git
DEPLOY_USERNAME="Travis CI"

all: docker build deploy

docker:
	  docker-compose build

build:
		docker-compose run --rm hugo hugo --theme spark -d /output --baseUrl=${BASE_URL}

deploy:
	 @GIT_DEPLOY_DIR=${DEPLOY_DIR} GIT_DEPLOY_BRANCH=${DEPLOY_BRANCH} GIT_DEPLOY_USERNAME=${DEPLOY_USERNAME} GIT_DEPLOY_REPO=${DEPLOY_REPO} ./scripts/subtree-master.sh

build-loc:
		docker-compose run --rm hugo hugo --buildDrafts --theme spark --baseUrl=http://tech.sparkfabrik.loc
