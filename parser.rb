
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

require 'mysqlconnector.rb'

class ParserLog
	def initialize
		@mysql = DBConnector.new
	end
	def parseLog(riga)
		id = /postfix\/smtpd\[\d*\]: ([aA-Z0-9]+): client=tomcat.mailalyzer.com/.match(riga)
		unless id[1] == nil
	    puts "Nuovo id "+id[1] if $DEBUG
		  @mysql.insert(id[1])
	  end
		id = /postfix\/cleanup\[\d*\]: ([aA-Z0-9]+): message-id=(.*)/.match(riga)
		unless id[1] == nil && id[2] == nil
	    puts "Id "+id[1]+" Message-Id "+id[2]  if $DEBUG
		  @mysql.update(id[1],id[2])
	  end
		id = /postfix\/smtp\[\d*\]: ([aA-Z0-9]+): to=.*status=(.*)/.match(riga)
		unless id[1] == nil && id[2] == nil
	    puts "Id "+id[1]+" status "+id[2] if $DEBUG
		  @mysql.update_status(id[1],id[2])
		end
	end
end

#file =File.new("/tmp/mail.log")
#file.readlines.each{|r| parseLog(r)}
