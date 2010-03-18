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

require 'mysql'
require 'socket'

class DBConnector
	def initialize
		# dati per la connessione al DBMS
		# host
		# username
		# password
		# nome del database
		@con = Mysql.new($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME)
		
		@myhostname = Socket.gethostname
		# query di selezione
		#rs = con.query('select field from tabella')
		
		# ciclo per l'estrazione dei dati
		#rs.each_hash {|h| puts h['field']}
		
		# chiusura della connessione
		#con.close
	end

	def at_exit
		@con.close
	end

	def insert(id)
#		puts "insert into postfix_logs (postfix_id) VALUES (\'#{id}\');"
    query = "insert into postfix_logs (postfix_id, hostname) VALUES (\'#{id}\',\'#{@myhostname}\')"
    puts query if $DEBUG
		result = @con.query(query)
    puts result.inspect if $DEBUG
	end

	def update(id, messageid) 
	  query = "update postfix_logs set message_id= \'#{messageid}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'"
		begin
			result = @con.query(query)
    		puts result.inspect if $DEBUG
		rescue Mysql::Error => e
			puts "Error Message: #{e.error}"
		end
	end

	def good_delivered(id, status, status_code)
	  query = "update postfix_logs set delivery_success=\'yes\', status=\'#{status}\', status_code=\'#{status_code}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'"
		begin
			result = @con.query(query)
    		puts result.inspect if $DEBUG
		rescue Mysql::Error => e
			puts "Error Message: #{e.error}"
		end

	end

	def bad_delivered(id,status)
	  query = "update postfix_logs set delivery_success=\'no\', status=\'#{status}\', status_code=\'#{status_code}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'"
		begin
			result = @con.query(query)
	  		puts result.inspect if $DEBUG
		rescue Mysql::Error => e
			puts "Error Message: #{e.error}"
		end
	end
	
	def update_status(id,status, status_code = 0)
		if status.rindex('sent') == nil
			bad_delivered(id,status, status_code.to_i)
		else
			good_delivered(id,status, status_code.to_i)
		end
	end
end
