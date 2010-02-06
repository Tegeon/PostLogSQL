require 'mysql'
require "socket"



class DBConnector
	def initialize
		# dati per la connessione al DBMS
		# host
		# username
		# password
		# nome del database
		@con = Mysql.new('db_host', 'db_user', 'db_pass','db_name')
		
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
		result = @con.query("insert into postfix_logs (postfix_id, hostname) VALUES (\'#{id}\',\'#{@myhostname}\')")
#		puts result.inspect
	end

	def update(id, messageid) 
		result = @con.query("update postfix_logs set message_id= \'#{messageid}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'")
#		puts result.inspect
	end

	def good_delivered(id,status)
		result = @con.query("update postfix_logs set status=\'yes\', status=\'#{status}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'")
#		puts result.inspect

	end

	def bad_delivered(id,status)
		result = @con.query("update postfix_logs set status=\'no\', status=\'#{status}\' where postfix_id=\'#{id}\' AND hostname=\'#{@myhostname}\'")
	#	puts result.inspect
	end
	
	def update_status(id,status)
		if status.rindex('sent') ==nil
			bad_delivered(id,status)
		else
			good_delivered(id,status)
		end
	end
end
