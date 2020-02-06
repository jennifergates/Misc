#Module to parse and log router's firewall logs sent to syslog

#load processes the __load__.bro scripts in the directories loaded 
#which basically includes libraries
@load base/protocols/syslog
@load base/protocols/conn

#create namespace 
module RouterDHCP;

export {
	#Create an ID for our new stream. 
	redef enum Log::ID += { LOG };

	#Define the record type that will contain the data to log.
	type Info: record {
		syslog_ts: time 	&log;
		syslog_uid: string 	&log;
		fw_ts: string 		&log;
		ip_assigned: addr	&log;
		mac_addr: string	&log;
		hostname: string 	&log;
	};
}

event bro_init()  &priority=5
{
	#Create the stream. this adds a default filter automatically
	Log::create_stream(RouterDHCP::LOG, [$columns=Info, $path="RouterDHCP"]);
}

#add a new field to the connection record so that data is accessible in variety of event handlers
redef record connection += {
	routerdhcp: Info &optional;
};


#use syslog_message event as defined in Bro_Syslog.events.bif.bro
event syslog_message(c:connection; facility:count; severity:count; msg: string)
{
	#split message field to get data we want
	local messagedata = split_string(c$syslog$message, / /);
	local fw_time = cat_sep(" ", "-", messagedata[0], messagedata[1], messagedata[2], messagedata[3]);

	#log any ACCEPT or DROP message from the firewall 
	if (( "DHCPACK" in msg))
	{
		#local ipassigned = to_addr(messagedata[5]);
		#local macaddr = messagedata[6];
		#local host = cut_tail(messagedata[7],1);
		local ipassigned = to_addr(messagedata[6]);
		local macaddr = messagedata[7];
		local host = cut_tail(messagedata[8],1);

		local rec: RouterDHCP::Info = [$syslog_ts=c$syslog$ts, $syslog_uid=c$uid, $fw_ts=fw_time, $ip_assigned=ipassigned, $mac_addr=macaddr, $hostname=host];
		
		c$routerdhcp = rec;
		Log::write(RouterDHCP::LOG, rec);
	};
}
