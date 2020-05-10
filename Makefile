RELEASE_DIR = scripts/release
TESTING_DIR = scripts/testing
REPO_SCRIPT_RELEASE_DIR = repo/master/scripts
REPO_SCRIPT_TESTING_DIR = repo/dev/scripts

REMOTE = https://github.com/Night-Stalkers/ns-scripts.git

REPO_RELEASE_SCRIPTS = $(wildcard $(REPO_SCRIPT_RELEASE_DIR)/*.py)
REPO_TESTING_SCRIPTS = $(wildcard $(REPO_SCRIPT_TESTING_DIR)/*.py)

RELEASE_SCRIPTS = $(patsubst $(REPO_SCRIPT_RELEASE_DIR)/%.py, $(RELEASE_DIR)/%.py, $(wildcard $(REPO_SCRIPT_RELEASE_DIR)/*.py))
TESTING_SCRIPTS = $(patsubst $(REPO_SCRIPT_TESTING_DIR)/%.py, $(TESTING_DIR)/%.py, $(wildcard $(REPO_SCRIPT_TESTING_DIR)/*.py))

testing: pull_testing $(TESTING_SCRIPTS)
	@echo "[INFO] TESTING scripts successfully updated."

release: pull_release $(RELEASE_SCRIPTS)
	@echo "[INFO] RELEASE scripts successfully updated."

test:
	@echo "REPO_MASTER = $(REPO_RELEASE_SCRIPTS)"
	@echo "REPO_DEV = $(REPO_TESTING_SCRIPTS)"
	@echo "RS = $(RELEASE_SCRIPTS)"
	@echo "TS = $(TESTING_SCRIPTS)"

setup:
	@echo "[INFO] Setting up ns-scripts-manager..."
	mkdir -p repo/master
	git clone $(REMOTE) repo/master
	cp -r repo/master repo/dev
	mkdir -p $(RELEASE_DIR) $(TESTING_DIR)
	touch servers.txt
	@test -s servers.txt || printf "REPLACE THIS WITH YOUR SERVERS' PATH AND TYPE SEPARATED BY A SPACE. ONE ENTRY PER LINE.\nUSE ABSOLUTE PATHS!\n/home/user/servers/server_01 RELEASE\n/home/user/servers/server_02 TESTING\nONE ENTRY PER LINE." >> servers.txt
	@echo "[INFO] You will now start editing the server configuration in servers.txt."
	@echo "[INFO] This will open the file in vi."
	@echo "[INFO] If you are unfamiliar with vi: Press i to go into insert mode, <ESC> to go back to normal mode."
	@echo "[INFO] Once you are finished adding your entries, go back to normal mode and type ':wq' and hit <RETURN> to save and quit."
	@read -p "[INFO] Press enter to continue..."
	@vi servers.txt
	@sleep 1
	@echo "[INFO] Starting servers setup..."
	@./setup-servers.sh
	@echo "[INFO] Setup finished."

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

.PHONY: clean backup restore unlink relink

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

unlink:
	@./unlink.sh

relink:
	@./setup-servers.sh

