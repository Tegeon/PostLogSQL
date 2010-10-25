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
#
# Author:: Matteo Rosi
# Author:: Tommaso Visconti <tommaso.visconti@kreations.it>
# License:: GPLv3

require 'deliveryrecord.rb'
require 'socket'

class ParserLog
	def initialize
		@myhostname = Socket.gethostname
	end
	
	def parseLog(riga)
		id = /postfix\/smtpd\[\d*\]: ([aA-Z0-9]+): client=tomcat.mailalyzer.com/.match(riga)
		
		unless id == nil || id[1] == nil
	    puts "Nuovo id "+id[1] if $DEBUG
	    
	    @record = DeliveryRecord.new
		  
		  @record.postfix_id = id[1]
	  	@record.hostname = @myhostname
	  	@record.start_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	  	
	  	@record.save
	  	
	  end
		
		id = /postfix\/cleanup\[\d*\]: ([aA-Z0-9]+): message-id=(.*)/.match(riga)
		
		unless id == nil || id[1] == nil || id[2] == nil
	    puts "Id "+id[1]+" Message-Id "+id[2]  if $DEBUG
	    @record = DeliveryRecord.where(:postfix_id => id[1], :hostname => @myhostname)
		  @record.update_attribute(:message_id, id[2])
	  end
		
		id = /postfix\/smtp\[\d*\]: ([aA-Z0-9]+): to=.*status=(.*\(([0-9]{3})?(.*)\))/.match(riga)
		
		unless id == nil || id[1] == nil || id[2] == nil 
	    puts "Id "+id[1]+" status "+id[2] if $DEBUG	
		  code = 0
		  code = id[3] unless id[3] == nil
		  @record = DeliveryRecord.where(:postfix_id => id[1], :hostname => @myhostname)
		  @record.update_status(id[2], id[3])
		end
	end
end
