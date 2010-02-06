$LOAD_PATH << '/opt/postlogsql'

require 'thread'
require 'parser.rb'

def startDaemon
	exit if fork                   # Parent exits, child continues.
	Process.setsid                 # Become session leader.
	exit if fork                   # Zap session leader. See [1].
	Dir.chdir "/"                  # Release old working directory.
	File.umask 0000                # Ensure sensible umask. Adjust as needed.
	
	$stdout.reopen(File.new("/tmp/daemon.log","w"))
	$stderr.reopen($stdout)
	
	STDIN.reopen "/dev/null"       # Free file descriptors and
	#STDOUT.reopen "/dev/null", "a" # point them somewhere sensible.
	#STDERR.reopen STDOUT           # STDOUT/ERR should better go to a logfile.
	
	parseCmdLine(ARGV)
	
	while 1
	         puts "--MARK--\n" if Settings.instance().getDebugLevel() > 1
	         $stdout.flush
	         sleep 10
	end
end

class MailLogParser
	def initialize(file2parse)
		@@file2parse = file2parse
		@queue = Queue.new
		@@parser = ParserLog.new
	end

	def fifo_build
		producer = Thread.new do
			IO.popen(@@file2parse) do |pipe|
			  # Saves child pid
				pidfile = File.new('/var/run/postlogsql.pid', 'w')
				pidfile.puts(pipe.pid)
				pidfile.close	
   				pipe.sync = true
   				while str = pipe.gets
#     					@queue << str
#					puts "START #{str} STOP"
					@@parser.parseLog(str)
	   			end
			end
		end
		return producer
	end
end

parser = MailLogParser.new("tail -F -n 0 /var/log/mail.log")
p = parser.fifo_build
p.join
