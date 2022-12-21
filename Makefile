ui:
	cd src/frontend/
	npm install 
	npm run build
server:
	cd src/backend/
	gradle clean build -x test
release:
	rm -Rf /opt/job
	mkdir -p /opt/job
	cp -Rf ./VERSION /opt/job
	cp -Rf ./projects.yaml /opt/job
	cp -Rf ./release.md  /opt/job
	cp -Rf ./README.md  /opt/job 
	cp -Rf ./support-files /opt/job 
	cp -Rf ./UPGRADE.md /opt/job 
	cp -Rf ./src/frontend/dist /opt/job/frontend

	mkdir -p /opt/job/backend/job-analysis/bin
	cp -Rf ./scripts/job-analysis/job-analysis.sh /opt/job/backend/job-analysis/bin
	cp -Rf ./src/backend/release/job-analysis*.jar /opt/job/backend/job-analysis/job-analysis.jar
	
	mkdir -p /opt/job/backend/job-backup/bin
	cp -Rf ./scripts/job-backup/job-backup.sh /opt/job/backend/job-backup/bin
	cp -Rf ./src/backend/release/job-backup*.jar /opt/job/backend/job-backup/job-backup.jar

	mkdir -p /opt/job/backend/job-config/bin
	cp -Rf ./scripts/job-config/job-config.sh /opt/job/backend/job-config/bin
	cp -Rf ./src/backend/release/job-config*.jar /opt/job/backend/job-config/job-config.jar

	mkdir -p /opt/job/backend/job-config/bin
	cp -Rf ./scripts/job-config/job-config.sh /opt/job/backend/job-config/bin
	cp -Rf ./src/backend/release/job-config*.jar /opt/job/backend/job-config/job-config.jar

	mkdir -p /opt/job/backend/job-crontab/bin
	cp -Rf ./scripts/job-crontab/job-crontab.sh /opt/job/backend/job-crontab/bin
	cp -Rf ./src/backend/release/job-crontab*.jar /opt/job/backend/job-crontab/job-crontab.jar

	mkdir -p /opt/job/backend/job-execute/bin
	cp -Rf ./scripts/job-execute/job-execute.sh /opt/job/backend/job-execute/bin
	cp -Rf ./src/backend/release/job-execute*.jar /opt/job/backend/job-execute/job-execute.jar

	mkdir -p /opt/job/backend/job-gateway/bin
	cp -Rf ./scripts/job-gateway/job-gateway.sh /opt/job/backend/job-gateway/bin
	cp -Rf ./src/backend/release/job-gateway*.jar /opt/job/backend/job-gateway/job-gateway.jar

	mkdir -p /opt/job/backend/job-logsvr/bin
	cp -Rf ./scripts/job-logsvr/job-logsvr.sh /opt/job/backend/job-logsvr/bin
	cp -Rf ./src/backend/release/job-logsvr*.jar /opt/job/backend/job-logsvr/job-logsvr.jar

	mkdir -p /opt/job/backend/job-manage/bin
	cp -Rf ./scripts/job-manage/job-manage.sh /opt/job/backend/job-manage/bin
	cp -Rf ./src/backend/release/job-manage*.jar /opt/job/backend/job-manage/job-manage.jar

	cp -Rf ./src/backend/release/upgrader*.jar  /opt/job/backend/upgrader-3.5.1.jar

	cp -Rf ./docs/ /opt/job/

	cd /opt/
	tar -zcvf ./job_ce-3.5.1.tgz job/