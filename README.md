# NS Scripts Manager
A simple GNU Make based scripts manager for PySnip server scripts. Useful for managing scripts of multiple PySnip server instances. It allows you to easily have multiple PySnips instances loading their scripts from a same directory. It also allows you to pull changes from a git repository, and automatically apply the changes to the scripts directory, that way the all the server instances get the updated scripts without having to manually copy files.

## How does it work?
The functionality of this Makefile relies on symlinks and git. To achieve synchronization between all server scripts, ns-scripts-manager uses two main directories:
* `scripts/release/`
* `scripts/testing/`

These two directories are the places where scripts will be located. 
* The **release** directory is intended for stable scripts, used by _production_ servers, in other words, the **release** directory will hold all the scripts that have been tested and are confirmed to be stable. _Production_ servers are intended to symlink their `feature_server/scripts/` directory to `scripts/release/`.
* The **testing** directory is intended for scripts which are still being tested and may not be stable yet, which are used by _testing_ servers. _Testing_ servers are intended to symlink their `feature_server/scripts/` directory to `scripts/testing/`.

Once all the servers are set up and the symlinks are ready, the update-from-git feature may be used. This requires you to have a git repo set up, by default the Makefile is set to use the *master* and *dev* branches from the **ns-scripts** repo for scripts updates, of course you can modify these settings to fit your use case. Once you have modified the Makefile to use your repo (if you have one), you can run the `make setup` command to clone and set up two local copies of the repository, one for each branch. By default, ns-scripts-manager uses the following branches:


| Git Branch | Applies Changes to |
| :---: | :---: |
| master | release |
| dev | testing |


Once you run the `make setup` command, you can start using the update from git feature. Now you can run either `make release` or `make testing` to automatically grab changes from the selected branch and apply them to the according directories. Make will only update scripts in the central directories if there have been changes in the according git branch. You can also run `make clean` to remove the downloaded repos. `make backup` backups the central scripts directories into `backup/release` and `backup/testing`, accordingly. Backups (if they exist) can be restored by using `make restore`, this will delete the existing scripts and restore the ones in backup to the central scripts directories, so be careful. 

## Usage
### Setting it up:
1. Clone this repo:

```console
$ git clone https://github.com/Night-Stalkers/ns-scripts-manager.git && cd ns-scripts-manager
```

2. Modify Makefile if needed (***Note to N-S Staff**: this is not needed by default if using for N-S Servers.*).
3. Setup ns-scripts-manager:

```console
$ make setup
```
4. Copy already existing scripts from servers to ns-scripts-manager central scripts directories:
```console
$ cd YOUR_SERVER_ROOT_DIR/feature_server
```
- Copy all your existing scripts into the ns-scripts-manager/release and ns-scripts-manager/testing directories.
```console
$ cp -r scripts/* PATH_TO_NS_SCRIPTS_MANAGER/scripts/release
$ cp -r scripts/* PATH_TO_NS_SCRIPTS_MANAGER/scripts/testing
```
- Repeat this step for every server, that way *ALL* of the already existing server scripts end up in the central scripts directories.

5. Create symlinks from servers to ns-scripts-manager:
- Backup server scripts folder before creating symlink, just in case.
```console
$ mv scripts/ scripts_bkp/
```
- Now let's create the symlink
- If the current server is a **RELEASE** server run:
```console
$ ln -s PATH_TO_NS_SCRIPTS_MANAGER/scripts/release/ scripts
```
- Otherwise, if the current server is a **TESTING** server run:
```console
$ ln -s PATH_TO_NS_SCRIPTS_MANAGER/scripts/testing/ scripts
```
- Repeat this step for every server, remember to symlink to the correct directory according to the type of server you are currently symlinking.

6. Start the servers, if you did everything correctly. The scripts should load and the server should start with no problems.

### Updating scripts from git:

1. Run (from the ns-scripts-manager root directory):
- To update **RELEASE** scripts:
```console
$ make release
```
- To update **TESTING** scripts (this is the default when running make without arguments):
```console
$ make testing
```
