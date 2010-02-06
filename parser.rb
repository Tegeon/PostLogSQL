require 'mysqlconnector.rb'

class ParserLog
	def initialize
		@mysql = DBConnector.new
	end
	def parseLog(riga)
		id = /postfix\/smtpd\[\d*\]: ([aA-Z0-9]+): client=tomcat.mailalyzer.com/.match(riga)
	#	puts "Nuovo id "+id[1] unless id == nil
		@mysql.insert(id[1]) unless id == nil
		id = /postfix\/cleanup\[\d*\]: ([aA-Z0-9]+): message-id=(.*)/.match(riga)
	#	puts "Id "+id[1]+" Message-Id "+id[2]  unless id == nil
		@mysql.update(id[1],id[2])  unless id == nil
		id = /postfix\/smtp\[\d*\]: ([aA-Z0-9]+): to=.*status=(.*)/.match(riga)
	#	puts "Id "+id[1]+" status "+id[2] unless id == nil
		@mysql.update_status(id[1],id[2]) unless id == nil
	end
end

#file =File.new("/tmp/mail.log")
#file.readlines.each{|r| parseLog(r)}
