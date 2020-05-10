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
The *servers.txt* file is where your server configuration goes. At setup, it is created and you are given the opportunity to modify it. Here you should add the path to each PySnip server and it's type (either **RELEASE** or **TESTING**), separated by a space. Only one entry per line is allowed. You *HAVE* to use absolute paths, otherwise you'll run into problems when symlinking occurs. The format of each entry is:

`/ABSOLUTE/PATH/TO/SERVER/DIRECTORY TYPE`

An example of a `servers.txt` file would be:
```
/home/user/AoS/servers/server0 RELEASE
/home/user/AoS/servers/server1 RELEASE
/home/user/testing/PySnip/test_server TESTING
/srv/AoS/PySnip/ABCServer TESTING
/srv/AoS/PySnip/XYZServer TESTING
```

## Usage
### Setting it up:
1. Clone this repo:

```console
$ git clone https://github.com/Night-Stalkers/ns-scripts-manager.git && cd ns-scripts-manager
```

2. Modify Makefile if needed. (***Note to N-S Staff**: this is not needed by default if using for N-S Servers.*).
3. Start the ns-scripts-manager setup:

```console
$ make setup
```
4. During the setup, you'll be asked to input your server configuration into *servers.txt*. Refer to the examples above. The *servers.txt* file should only contain server entries in the format above, no comments or anything else, otherwise it won't work. When you are given the chance to modify the *servers.txt* file during setup, make sure to delete **ALL** the placeholder text before adding your entries.
5. The setup will read your configuration and handle the symlinking process to the adequate directory. The setup will also backup each individual servers' `feature_server/scripts` directory to `feature_server/scripts_bkp`, this backup is restored when running `make unlink`.
6. The setup will also automatically populate the `scripts/release` and `scripts/testing` directories if they are empty. It will use the scripts from all servers with type **RELEASE** to populate `scripts/release` and the scripts from all servers with type **TESTING** to populate `scripts/testing`. This way you don't need to copy scripts manually after setup.
5. Start the servers. If everything went correctly, the scripts should load from their appropiate central scripts directory and the server should start with no problems.

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
- If for some reason you want to clean the repo directory, you can run:
```console
$ make clean
```
Which will remove the git repo that was cloned during setup. Since after running this command the repo will be gone, you will have to run `make setup` again in order to be able to update scripts from git.

### Relinking and unlinking:

1. If you change the servers' configuration, for example, if you change a server's type and want ns-scripts-manager to update the symlinks accordingly, you can run:
```console
$ make relink
```
- It will read the *servers.txt* file and update the symlinks accordingly.

2. If you want unlink the servers' symlinks for some reason, ns-scripts-manager handles this automatically for you. You can run:
```console
$ make unlink
```
- It will remove the symlinks and it will restore the scripts directory backup for each individual server.

## Backing up and restoring:

1. If you want to back up the contents of the central scripts directories, you can use:
```console
$ make backup
```
- It will create a copy of the `scripts/release` and `scripts/testing` directories in `backup/release` and `backup/testing` accordingly.

2. If you want to restore these backups, you can run:
```console
$ make restore
```
- This empties the `scripts/release` and `scripts/testing` directories and then copies the contents of `backup/release` and `backup/tesing` to their respective directories. Since this deletes the existing scripts in the central scripts directories, you should be careful and only use it if absolutely necessary.
