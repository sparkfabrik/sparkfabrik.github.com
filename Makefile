BASE_URL="http://sparkfabrik.github.io"
DEPLOY_DIR=output
DEPLOY_BRANCH=master
REPO=https://${GITHUB_TOKEN}@github.com/sparkfabrik/sparkfabrik.github.com.git
DEPLOY_USERNAME="Travis CI"

deploy:
		docker-compose build
		docker-compose run --rm hugo hugo --buildDrafts --theme spark -d /output --baseUrl=${BASE_URL}
		GIT_DEPLOY_DIR=${DEPLOY_DIR} GIT_DEPLOY_BRANCH=${DEPLOY_BRANCH} GIT_DEPLOY_USERNAME=${DEPLOY_USERNAME} REPO=${REPO} ./scripts/subtree-master.sh
