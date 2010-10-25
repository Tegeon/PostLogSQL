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


require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

# ActiveRecord configurations
dbconfig = YAML::load(File.open('database.yml'))
# Database connection
ActiveRecord::Base.establish_connection(dbconfig)
# Put the log into database.log
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))

# The DeliveryRecord class saves the delivery status to the DB using ActiveRecord.
# It's called by parser.rb which saves initial insert and first update,
# but doesn't save the delivery result which is saved by update_status
# which calls good_delivered or bad_delivered
class DeliveryRecord < ActiveRecord::Base

	set_table_name "postfix_logs"
	
	# The delivery went fine
	def good_delivered(status, status_code)
		self.update_attributes(:delivery_success => 'yes', :status => status, :status_code => status_code, :last_update => Time.now.strftime("%Y-%m-%d %H:%M:%S"))
	end

	# Something wrong appened during delivery
	def bad_delivered(status, status_code)
		self.update_attributes(:delivery_success => 'no', :status => status, :status_code => status_code, :last_update => Time.now.strftime("%Y-%m-%d %H:%M:%S"))
	end
	
	# Check the status then update
	def update_status(status, status_code = 0)
		if status.rindex('sent') == nil
		  status_code = $1 if status.match(/(\s[0-9]{3}\s)/)
			bad_delivered(status, status_code.to_i)
		else
			good_delivered(status, status_code.to_i)
		end
	end
end
