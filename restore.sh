echo "[WARNING] This will delete the existing RELEASE and TESTING scripts and replace them with the backup versions."
echo "[WARNING] Are you sure you want to continue?"
read -p "Press enter to continue..."
read -p "Are you sure? [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	# do dangerous stuff
	echo "[INFO] Restoring backed up scripts..."
fi
