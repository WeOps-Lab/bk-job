RELEASE_PATH=/opt/release/job

ui:
	cd src/frontend/  && npm install  && npm run build
server:
	cd src/backend/ && gradle clean build -x test
release:
	rm -Rf $(RELEASE_PATH)  &&\
	mkdir -p $(RELEASE_PATH) &&\
	cp -Rf ./VERSION $(RELEASE_PATH) &&\
	cp -Rf ./projects.yaml $(RELEASE_PATH) &&\
	cp -Rf ./release.md  $(RELEASE_PATH) &&\
	cp -Rf ./README.md  $(RELEASE_PATH) &&\
	cp -Rf ./support-files $(RELEASE_PATH) &&\
	cp -Rf ./UPGRADE.md $(RELEASE_PATH) &&\
	cp -Rf ./src/frontend/dist $(RELEASE_PATH)/frontend &&\
	mkdir -p $(RELEASE_PATH)/backend/job-analysis/bin &&\
	cp -Rf ./scripts/job-analysis/job-analysis.sh $(RELEASE_PATH)/backend/job-analysis/bin &&\
	cp -Rf ./src/backend/release/job-analysis*.jar $(RELEASE_PATH)/backend/job-analysis/job-analysis.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-backup/bin &&\
	cp -Rf ./scripts/job-backup/job-backup.sh $(RELEASE_PATH)/backend/job-backup/bin &&\
	cp -Rf ./src/backend/release/job-backup*.jar $(RELEASE_PATH)/backend/job-backup/job-backup.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-config/bin &&\
	cp -Rf ./scripts/job-config/job-config.sh $(RELEASE_PATH)/backend/job-config/bin &&\
	cp -Rf ./src/backend/release/job-config*.jar $(RELEASE_PATH)/backend/job-config/job-config.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-config/bin &&\
	cp -Rf ./scripts/job-config/job-config.sh $(RELEASE_PATH)/backend/job-config/bin &&\
	cp -Rf ./src/backend/release/job-config*.jar $(RELEASE_PATH)/backend/job-config/job-config.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-crontab/bin &&\
	cp -Rf ./scripts/job-crontab/job-crontab.sh $(RELEASE_PATH)/backend/job-crontab/bin &&\
	cp -Rf ./src/backend/release/job-crontab*.jar $(RELEASE_PATH)/backend/job-crontab/job-crontab.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-execute/bin &&\
	cp -Rf ./scripts/job-execute/job-execute.sh $(RELEASE_PATH)/backend/job-execute/bin &&\
	cp -Rf ./src/backend/release/job-execute*.jar $(RELEASE_PATH)/backend/job-execute/job-execute.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-gateway/bin &&\
	cp -Rf ./scripts/job-gateway/job-gateway.sh $(RELEASE_PATH)/backend/job-gateway/bin &&\
	cp -Rf ./src/backend/release/job-gateway*.jar $(RELEASE_PATH)/backend/job-gateway/job-gateway.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-logsvr/bin &&\
	cp -Rf ./scripts/job-logsvr/job-logsvr.sh $(RELEASE_PATH)/backend/job-logsvr/bin &&\
	cp -Rf ./src/backend/release/job-logsvr*.jar $(RELEASE_PATH)/backend/job-logsvr/job-logsvr.jar &&\
	mkdir -p $(RELEASE_PATH)/backend/job-manage/bin &&\
	cp -Rf ./scripts/job-manage/job-manage.sh $(RELEASE_PATH)/backend/job-manage/bin &&\
	cp -Rf ./src/backend/release/job-manage*.jar $(RELEASE_PATH)/backend/job-manage/job-manage.jar &&\
	cp -Rf ./src/backend/release/upgrader*.jar  $(RELEASE_PATH)/backend/upgrader-3.5.1.jar &&\
	cp -Rf ./docs/ $(RELEASE_PATH) &&\
	cd ./versionLogs && python3 ./genBundledVersionLog.py &&\
	cd .. &&\
	mv ./versionLogs/bundledVersionLog.* $(RELEASE_PATH)/frontend/static/ 