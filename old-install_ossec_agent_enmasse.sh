#!/bin/bash
##########################################
#  ossec_install_agent_enmasse.sh script to install the ossec agent and configure it remotely. requires agent 
# installer files with the edited preloaded-vars.conf file archived with it for unattended install and password 
# to be entered interactively when run on. serverlist.txt should be one username:IP address per line for each 
# linux box to have agent installed on.	Ex: root:1.1.1.1			 
##########################################

if [ "$#" -lt 2 ];then
	echo "Usage: install_ossec_agent.sh /path/to/ssh_key /path/to/customAgent.tar.gz /path/to/serverlist.txt"
	
else	
	for LINE in $(cat $3); do
	#while IFS='' read -r LINE || [[ -n "$LINE" ]]; do

		KEY=$1
		TAR=$2
		USERNAME=${LINE%:*}
		HOST=${LINE##*:}
	
		echo "________________________________"
		echo "${USERNAME}@${HOST}"		
		echo "________________________________"
		echo "Using ${USERNAME} and ${KEY}, to connect to ${HOST} and install the ossec agent from ${TAR}."
		echo "SSH key passphrase and user password will need to be entered for each command."
		echo ""
		echo "[ ] Copying ${TAR} to host. Prompts for ssh key passphrase."
		scp -i $KEY $TAR ${USERNAME}@${HOST}:/tmp/ossec-hids-LS17-2.8.3.tar.gz
	
		echo "[ ] Extracting ${TAR} to /tmp/ on ${HOST}. Prompts for ssh key passphrase."
		ssh -i $KEY ${USERNAME}@${HOST} 'tar -zxf /tmp/ossec-hids-LS17-2.8.3.tar.gz -C /tmp/'
	
		echo "[ ] Installing prerequisites and running unattended install. Prompts for ssh key passphrase and user's password for sudo command."
		ssh -i $KEY ${USERNAME}@${HOST} -tt 'export DEBIAN_FRONTEND=noninteractive && apt-get install build-essential libssl-dev inotify-tools --assume-yes && cd /tmp/ossec-hids-2.8.3 && ./install.sh && /var/ossec/bin/agent-auth -m 10.11.5.2 -p 1515 && /var/ossec/bin/ossec-control restart'
		
		#servers without apt-get like asterisk .16 - comment out above line and uncomment below line
		#ssh -i $KEY ${USERNAME}@${HOST} -tt 'export DEBIAN_FRONTEND=noninteractive && yum install -y openssl-devel && cd /tmp/ossec-hids-2.8.3 && ./install.sh && /var/ossec/bin/agent-auth -m 10.11.5.2 -p 1515 && /var/ossec/bin/ossec-control restart'

		echo ""
	#done < $3
done

fi


exit 0
