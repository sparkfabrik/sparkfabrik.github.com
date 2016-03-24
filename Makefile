BASE_URL="http://sparkfabrik.github.io"
DEPLOY_DIR=output
DEPLOY_BRANCH=master

build:
		docker-compose build
		docker-compose run --rm hugo hugo --buildDrafts --theme spark -d /output --baseUrl=${BASE_URL}
		GIT_DEPLOY_DIR=${DEPLOY_DIR} GIT_DEPLOY_BRANCH=${DEPLOY_BRANCH} ./scripts/git.sh
