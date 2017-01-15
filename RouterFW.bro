#Module to parse and log router's firewall logs sent to syslog

#load processes the __load__.bro scripts in the directories loaded 
#which basically includes libraries
@load base/protocols/syslog
@load base/protocols/conn

#create namespace 
module RouterFW;

export {
	#Create an ID for our new stream. 
	redef enum Log::ID += { LOG };

	#Define the record type that will contain the data to log.
	type Info: record {
		syslog_ts: time 	&log;
		syslog_uid: string 	&log;
		fw_ts: string 		&log;
		packet_src: addr	&log;
		packet_dest: addr	&log;
		packet_dport: count &log;
		action: string  	&log;
	};
}

event bro_init()  &priority=5
{
	#Create the stream. this adds a default filter automatically
	Log::create_stream(RouterFW::LOG, [$columns=Info, $path="RouterFW"]);
}

#add a new field to the connection record so that data is accessible in variety of event handlers
redef record connection += {
	routerfw: Info &optional;
};


#use syslog_message event as defined in Bro_Syslog.events.bif.bro
event syslog_message(c:connection; facility:count; severity:count; msg: string)
{
	#split message field to get data we want
	local messagedata = split_string(c$syslog$message, / /);
	local fw_time = cat_sep(" ", "-", messagedata[0], messagedata[1], messagedata[2]);

	#log any ACCEPT or DROP message from the firewall 
	if (( "ACCEPT" in msg ) || ("DROP" in msg))
	{
		local action = messagedata[4];
		local src_ip = to_addr((split_string(messagedata[8], /=/ ))[1]);
		local dst_ip = to_addr((split_string(messagedata[9], /=/))[1]);
		local dst_p = to_count((split_string(messagedata[17], /=/))[1]);
		#print "GOT FW ACTION";
		#print c;
		local rec: RouterFW::Info = [$syslog_ts=c$syslog$ts, $syslog_uid=c$uid, $fw_ts=fw_time, $packet_src=src_ip, $packet_dest=dst_ip, $packet_dport=dst_p, $action=action];
		c$routerfw = rec;

		Log::write(RouterFW::LOG, rec);
	}
	
}