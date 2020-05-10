#!/bin/bash
OLDIFS=$IFS
IFS=" "
paths=()
types=()
links=()
FILE='servers.txt'

echo "Parsing '${FILE}'..."
sleep 1
if [[ ! -s "${FILE}" ]]; then
	echo "Error: Empty '${FILE}' file."
	exit 1
fi

# Read from file and verify it's correct
index=0
while read f1 f2
do
	if [[ -z "${f2}" ]] || [[ -z "${f1}" ]] || [[ "${f1}" = " " ]]; then
		echo "[${FILE}:$((index+1))] Syntax Error: Missing server type or server path."
		exit 1
	fi
	paths[index]=${f1}
	types[index]=${f2}
	if [[ "${f2}" != "RELEASE" ]] && [[ "${f2}" != "TESTING" ]]; then
		echo "[${FILE}:$((index+1))] Syntax Error: Unknown server type '${f2}'."
		exit 1
	fi
	((index++))
done < ${FILE}

# Verify servers are valid
echo "Verifying servers..."
sleep 1
for i in ${!paths[*]}
do
	if [[ ! -d "${paths[$i]}/feature_server" ]]; then
		echo "Server Verification Error: Server path '${paths[$i]}' is not a valid PySnip server path."
		exit 1
	fi
done

# Verify servers scripts folder
echo "Verifying scripts folders..."
sleep 1
for i in ${!paths[*]}
do
	if [[ -L "${paths[$i]}/feature_server/scripts" ]]; then
		links[i]=1
	else
		links[i]=0
	fi
done

# Calculate longest path

max=0
for i in ${!paths[*]}
do
	s=${paths[$i]}
	len=${#s}
	if [[ ${len} -gt ${max} ]]; then
		max=$len
	fi
done

# Print servers and their type
echo "Found servers:"
sleep 1
for i in ${!paths[*]}
do
	printf "\t%-${max}s -> %-7s" ${paths[$i]} ${types[$i]}
	if [[ ${links[$i]} -eq 1 ]]; then
		printf "\n\t\tSYMLINKED -> %s\n\n" $(readlink -- ${paths[$i]}/feature_server/scripts)
	else
		printf "\n"
	fi
done

sleep 2

function prompt () {
printf "\n"
read -p "$1 [y/n] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	return 0
else
	return 1
fi
}

echo "Servers scripts directories that are symlinked will be unlinked and have their scripts restored."
prompt "Is this okay?"
if test $? -eq 0; then
	:
else
	printf "Exiting."
	exit 1
fi

# Undo symlinks
echo "Undoing symlinks..."
sleep 1
for i in ${!paths[*]}
do
	if [[ ${links[$i]} -eq 1 ]]; then
		unlink ${paths[$i]}/feature_server/scripts
		if test $? -eq 0; then
			printf "Unlinked: '%s/feature_server/scripts'.\n" ${paths[$i]}
		else
			printf "Error unlinking symlink for server '%s'.\n" ${paths[$i]}
			exit 1
		fi
	fi
done

# Restore scripts from backup
echo "Restoring servers scripts from backups..."
sleep 1
for i in ${!paths[*]}
do
	if [[ -d ${paths[$i]}/feature_server/scripts_bkp ]]; then
		mv ${paths[$i]}/feature_server/scripts_bkp ${paths[$i]}/feature_server/scripts
		if test $? -eq 0; then
			printf "Restored backup: '%s/feature_server/scripts_bkp' -> '%s/feature_server/scripts'.\n" ${paths[$i]} ${paths[$i]}
		else
			printf "Error creating backup for '%s'.\n" ${paths[$i]}
			exit 1
		fi
	else
		printf "'%s/feature_server/scripts_bkp' doesn't exists, doing nothing.\n" ${paths[$i]}
	fi
done
