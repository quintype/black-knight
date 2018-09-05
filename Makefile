APP_NAME="black-knight"

create-whoami:
	touch whoami.yml
	echo "---" > whoami.yml
	echo "$(APP_NAME):" >> whoami.yml
	echo "  pipeline_name: $(CIRCLE_PROJECT_REPONAME)" >> whoami.yml
	echo "  pipeline_counter: $(CIRCLE_WORKFLOW_ID)" >> whoami.yml
	echo "  stage_counter: $(CIRCLE_BUILD_NUM)" >> whoami.yml
	echo "  location: https://circleci.com/gh/quintype/$(CIRCLE_PROJECT_REPONAME)/$(CIRCLE_BUILD_NUM)"
	

create-tar:
	make create-whoami
	RAILS_ENV=production NODE_ENV=production ./bin/build-tarball $(APP_NAME).tar "$@"
	tar rf $(APP_NAME).tar whoami.yml

upload-artifact:
	timestamp="$(date '+%Y-%m-%d-%T')"
	aws s3 cp /tmp/workspace/$(APP_NAME).tar  s3://qt-deploy-artifacts/$(APP_NAME)/$(timestamp)/$(APP_NAME).tar
