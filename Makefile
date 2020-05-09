RELEASE_DIR = scripts/release
TESTING_DIR = scripts/testing
REPO_SCRIPT_RELEASE_DIR = repo/master/scripts
REPO_SCRIPT_TESTING_DIR = repo/dev/scripts

REMOTE = https://github.com/Night-Stalkers/ns-scripts.git

REPO_RELEASE_SCRIPTS = $(wildcard $(REPO_SCRIPT_RELEASE_DIR)/*.py)
REPO_TESTING_SCRIPTS = $(wildcard $(REPO_SCRIPT_TESTING_DIR)/*.py)

RELEASE_SCRIPTS = $(patsubst $(REPO_SCRIPT_RELEASE_DIR)/%.py, $(RELEASE_DIR)/%.py, $(wildcard $(REPO_SCRIPT_RELEASE_DIR)/*.py))
TESTING_SCRIPTS = $(patsubst $(REPO_SCRIPT_TESTING_DIR)/%.py, $(TESTING_DIR)/%.py, $(wildcard $(REPO_SCRIPT_TESTING_DIR)/*.py))

test:
	@echo "REPO_MASTER = $(REPO_RELEASE_SCRIPTS)"
	@echo "REPO_DEV = $(REPO_TESTING_SCRIPTS)"
	@echo "RS = $(RELEASE_SCRIPTS)"
	@echo "TS = $(TESTING_SCRIPTS)"

setup:
	@echo "[INFO] Setting up repo..."
	mkdir -p repo/master
	git clone $(REMOTE) repo/master
	cp -r repo/master repo/dev
	@echo "[INFO] Setup finished."

release: pull_release $(RELEASE_SCRIPTS)
	@echo "[INFO] RELEASE scripts successfully updated."

testing: pull_testing $(TESTING_SCRIPTS)
	@echo "[INFO] TESTING scripts successfully updated."

$(RELEASE_DIR)/%.py: $(REPO_SCRIPT_RELEASE_DIR)/%.py
	cp $^ $@

$(TESTING_DIR)/%.py: $(REPO_SCRIPT_TESTING_DIR)/%.py
	cp $^ $@
	
pull_release:
	@echo "[INFO] Pulling scripts from master..."
	cd repo/master && git checkout master
	cd repo/master && git pull
	@echo "[INFO] Done."

pull_testing:
	@echo "[INFO] Pulling scripts from dev..."
	cd repo/dev && git checkout dev
	cd repo/dev && git pull
	@echo "[INFO] Done."

.PHONY: clean backup restore

clean:
	@echo "[INFO] Cleaning up..."
	rm -rf repo
	@echo "[INFO] Done."
	@echo "[INFO] Repos cleaned. Run 'make setup' before updating scripts again."

backup:
	@echo "[INFO] Backing up scripts..."
	@mkdir -p backup
	@echo "[INFO] Backing up RELEASE scripts..."
	@cp -r scripts/release backup/
	@echo "[INFO] Backing up TESTING scripts..."
	@cp -r scripts/testing backup/
	@echo "[INFO] Backup finished. Backup written to backup directory."

restore:
	@./restore.sh
