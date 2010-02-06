#!/usr/bin/env ruby

$LOAD_PATH << '/opt/postlogsql'

require 'rubygems'        # if you use RubyGems
require 'daemons'
Daemons.run('postlogsql.rb')

#require 'postlogsql.rb'
#pid = fork do
#	Signal.trap('HUP', 'IGNORE') # Don't die upon logout
#	parser = MailLogParser.new("tail -F -n 0 /var/log/mail.log")
#	p = parser.fifo_build
#	p.join
#end
#Process.detach(pid)
