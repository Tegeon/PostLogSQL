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

require 'mysql2'
require 'socket'

class DBConnector
	def initialize
		# dati per la connessione al DBMS
		# host
		# username
		# password
		# nome del database
  	@con = Mysql2::Client.new($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME)
		
		@myhostname = Socket.gethostname
	end

  def is_connection_alive?
    return !@con.nil?
  end
  
  def estabilish_connection
    is_connection_alive? or @con = Mysql.new($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME)
  end
  
	def at_exit
		@con.close
	end

	def insert(id)
	  self.estabilish_connection
	  
    query = "insert into postfix_logs (postfix_id, hostname, start_time) VALUES (\'#{id}\',\'#{@myhostname}\', '"+Time.now.strftime("%Y-%m-%d %H:%M:%S")+"')"
	  begin
		  result = @con.query(query)
      puts result.inspect if $DEBUG
	  rescue Mysql2::Error => e
      puts "Error Message: #{e.error}"
	  end
	end

	def update(id, messageid) 
	  self.estabilish_connection
	  
	  query = "update postfix_logs set message_id= \'#{messageid}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'"
		begin
			result = @con.query(query)
    	puts result.inspect if $DEBUG
		rescue Mysql2::Error => e
			puts "Error Message: #{e.error}"
		end
	end

	def good_delivered(id, status, status_code)
	  query = "update postfix_logs set delivery_success='yes', status='#{status}', status_code='#{status_code}', last_update='"+Time.now.strftime("%Y-%m-%d %H:%M:%S")+"' where postfix_id='#{id}' AND hostname='#{@myhostname}'"
		begin
			result = @con.query(query)
    	puts result.inspect if $DEBUG
		rescue Mysql2::Error => e
			puts "Error Message: #{e.error}"
		end

	end

	def bad_delivered(id, status, status_code)
	  query = "update postfix_logs set delivery_success='no', status='#{status}', status_code='#{status_code}', last_update='"+Time.now.strftime("%Y-%m-%d %H:%M:%S")+"'  where postfix_id='#{id}' AND hostname='#{@myhostname}'"
		begin
			result = @con.query(query)
	  	puts result.inspect if $DEBUG
		rescue Mysql2::Error => e
			puts "Error Message: #{e.error}"
		end
	end
	
	def update_status(id, status, status_code = 0)
	  self.estabilish_connection
	  
		if status.rindex('sent') == nil
		  status_code = $1 if status.match(/(\s[0-9]{3}\s)/)
			bad_delivered(id,status, status_code.to_i)
		else
			good_delivered(id,status, status_code.to_i)
		end
	end
end
