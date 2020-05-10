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

prompt "Is this okay?"
if test $? -eq 0; then
	:
else
	printf "Exiting."
	exit 1
fi

# Populate ns-scripts-manager/scripts directories with existing scripts
if [[ ! "$(ls -A scripts/release)" ]] && [[ ! "$(ls -A scripts/testing)" ]]; then
	echo "Populating central script directories..."
	sleep 1
	for i in ${!paths[*]}
	do
		if [[ ${types[$i]} == "RELEASE" ]] && [[ ! -L ${paths[$i]}/feature_server/scripts ]]; then
			cp ${paths[$i]}/feature_server/scripts/* $(pwd)/scripts/release/
			if test $? -eq 0; then
				printf "Populated: '%s/feature_server/scripts/*' -> '%s/scripts/release/'.\n" ${paths[$i]} $(pwd)
			else
				printf "Error populating scripts/release from '%s'.\n" ${paths[$i]}
				exit 1
			fi
		elif [[ ${types[$i]} == "TESTING" ]] && [[ ! -L ${paths[$i]}/feature_server/scripts ]]; then
			cp ${paths[$i]}/feature_server/scripts/* $(pwd)/scripts/testing/
			if test $? -eq 0; then
				printf "Populated: '%s/feature_server/scripts/*' -> '%s/scripts/testing/'.\n" ${paths[$i]} $(pwd)
			else
				printf "Error populating scripts/testing from '%s'.\n" ${paths[$i]}
				exit 1
			fi
		fi
	done
fi	

# Back up servers scripts
echo "Backing up servers scripts..."
sleep 1
for i in ${!paths[*]}
do
	if [[ -d ${paths[$i]}/feature_server/scripts_bkp ]]; then
		printf "'%s/feature_server/scripts_bkp' already exists, doing nothing.\n" ${paths[$i]}
	else
		mv ${paths[$i]}/feature_server/scripts ${paths[$i]}/feature_server/scripts_bkp
		if test $? -eq 0; then
			printf "Created backup: '%s/feature_server/scripts' -> '%s/feature_server/scripts_bkp'.\n" ${paths[$i]} ${paths[$i]}
		else
			printf "Error creating backup for '%s'.\n" ${paths[$i]}
			exit 1
		fi
	fi
done

sleep 1

# Create symlinks
echo "Creating symlinks..."
sleep 1
for i in ${!paths[*]}
do
	if [[ ${links[$i]} -eq 1 ]]; then
		type_=$(echo "${types[$i]}" | tr '[:upper:]' '[:lower:]')
		target="$(pwd)/scripts/${type_}"
		printf "\nServer scripts directory '%s/feature_server/scripts' is already symlinked:\n" ${paths[$i]}
		printf "\t%s -> %s\n" "${paths[$i]}/feature_server/scripts" $(readlink -- ${paths[$i]}/feature_server/scripts)
		prompt "Do you wish to modify this symlink?"
		if test $? -eq 0; then
			ln -sfn ${target} ${paths[$i]}/feature_server/scripts
			if test $? -eq 0; then
				printf "Created symlink:\n\t'%s/feature_server/scripts' -> '%s'.\n" ${paths[$i]} ${target}
			else
				printf "Error creating symlink for server '%s'.\n" ${paths[$i]}
				exit 1
			fi
		else
			printf "Skipping.\n"
		fi
	else
		type_=$(echo "${types[$i]}" | tr '[:upper:]' '[:lower:]')
		target="$(pwd)/scripts/${type_}"
		ln -s ${target} ${paths[$i]}/feature_server/scripts
		if test $? -eq 0; then
			printf "Created symlink:\n\t'%s/feature_server/scripts' -> '%s'.\n" ${paths[$i]} ${target}
		else
			printf "Error creating symlink for server '%s'.\n" ${paths[$i]}
			exit 1
		fi
		
	fi
done

echo "Servers are ready!"
exit 0
