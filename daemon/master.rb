#!/usr/bin/env ruby

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
