
# This file is part of PostLogSQL.
# PostLogSQL is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# PostLogSQL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with PostLogSQL.  If not, see <http://www.gnu.org/licenses/>.

$LOAD_PATH << '/opt/postlogsql'
$DEBUG = true

require 'configurations.rb'
require 'thread'
require 'parser.rb'

class MailLogParser
	def initialize(file2parse)
		@@file2parse = file2parse
		@queue = Queue.new
		@@parser = ParserLog.new
		@@pidfile = File.new('/var/run/postlogsql_child.pid', 'w')
	end
	
	def at_exit
		@@pidfile = File.new('/var/run/postlogsql_child.pid', 'w')
		pid = @@pidfile.readline.to_i
		puts "Sending signal 9 to process with pid #{pid}" if $DEBUG
		Process.kill(9,pid)
	end

	def fifo_build
		producer = Thread.new do
			IO.popen(@@file2parse) do |pipe|
			  # Saves child pid
				@@pidfile.puts(pipe.pid)
				@@pidfile.close	
   				pipe.sync = true
   				while str = pipe.gets
#     					@queue << str
#					puts "START #{str} STOP"
          puts "Leggo:\n"+str+"\n" if $DEBUG
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
