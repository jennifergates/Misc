#!/bin/bash
##########################################
#  ossec_install_agent.sh                #
#  script to install the ossec agent and #
#  configure it remotely.						 #
##########################################




if [ "$#" -lt 2 ];then
	echo "Usage: ossec_install_agent.sh /path/to/ssh_keys username serverIP"
	
else	
	KEY=$1
	USERNAME=$2
	HOST=$3

	echo "${KEY}, ${USERNAME}, ${HOST}"
		

	# Install certificate with no password to avoid being prompted for password each connection
	if [ -f $KEY ];then 
		echo "COPYING SSH KEY"
		ssh-copy-id -i $KEY".pub" ${USERNAME}@${HOST}
	else 
		echo "$KEY : no such file"
		exit 0
	fi

	# Get OSSEC Agent installer archive file from web if we don't have it, replace conf file for unattended install
	# and re-tar it for scp to host
	if [ ! -f ./ossec-hids-LS17-2.8.3.tar.gz ]; then
		echo "DOWNLOADING AGENT INSTALLER"
		wget -q -U ossec -O /tmp/ossec-hids-2.8.3.tar.gz https://bintray.com/artifact/download/ossec/ossec-hids/ossec-hids-2.8.3.tar.gz --no-check-certificate
		echo "EXTRACTING FILES"
		tar -zxf /tmp/ossec-hids-2.8.3.tar.gz -C /tmp/
		echo "COPYING UNATTENDED INSTALL CONF FILE"
		cp /tmp/ossec-hids-2.8.3/etc/preloaded-vars.conf /tmp/ossec-hids-2.8.3/etc/preloaded-vars_conf.bak
		cp ./preloaded-vars.conf /tmp/ossec-hids-2.8.3/etc/
		mv /tmp/ossec-hids-2.8.3 /tmp/ossec-hids-LS17-2.8.3
		echo "ARCHIVING FOR TRANSFER TO HOST"
		tar -C /tmp -czf /tmp/ossec-hids-LS17-2.8.3.tar.gz ossec-hids-LS17-2.8.3/
	else
		cp ./ossec-hids-LS17-2.8.3.tar.gz /tmp/ossec-hids-2.8.3.tar.gz
	fi

	#copy tar  to host
	scp -i $KEY /tmp/ossec-hids-LS17-2.8.3.tar.gz ${USERNAME}@${HOST}:/tmp/ossec-hids-LS17-2.8.3.tar.gz
	#extract
	ssh -i $KEY ${USERNAME}@${HOST} 'tar -zxf /tmp/ossec-hids-LS17-2.8.3.tar.gz -C /tmp/'
	# install prerequisites and run unattended install NOTE: Requires entering password for user to sudo
	ssh -i $KEY ${USERNAME}@${HOST} -t 'export DEBIAN_FRONTEND=noninteractive && sudo apt-get install build-essential libssl-dev --assume-yes && cd /tmp/ossec-hids-LS17-2.8.3 && sudo ./install.sh && sudo /var/ossec/bin/agent-auth -m 192.168.41.104 =p 1515'
	# run unattended install
	#ssh -i $KEY ${USERNAME}@${HOST} -t 'cd /tmp/ossec-hids-LS17-2.8.3 && export DEBIAN_FRONTEND=noninteractive && sudo ./install.sh'		
	
	#ssh -i $KEY ${USERNAME}@${HOST} 'cp /tmp/ossec-hids-2.8.3/etc/preloaded-vars.conf /tmp/ossec-hids-2.8.3/etc/preloaded-vars_conf.bak'
	#ssh -i $KEY ${USERNAME}@${HOST} "sed 's_#\(.*USER\_LANGUAGE=\"en\".*\)_\1_' /tmp/ossec-hids-2.8.3/etc/preloaded-vars.conf"
	#ssh -i $KEY ${USERNAME}@${HOST} 'chmod 775 /tmp/ossec-hids-2.8.3/etc/preloaded-vars.conf'	
fi


exit 0