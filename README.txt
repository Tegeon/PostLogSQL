= PostLogSQL

In brief, PostLogSQL goal is to save postfix logs into a MySQL database.
This is very useful if you send an email with your software using the smtp server on localhost, which relay the mail to other servers. In this case you can't directly check the real shipping of the message.

If PostLogSQL is running in the deliver servers and all its instances are writing on the same MySQL server, using the <message-id> header (set from your software) you can check the shipping status.

The PostLogSQL scripts are into /daemon folder.
The /interface folder contains a simple web interface, useful to check delivery status. The app is written with Sinatra and uses ActiveRecord (See "Installation").

== Installation

=== Daemon

1) Put the files in /opt/postlogsql (if you choose a different path change it into master.rb and postlogsql.rb)

2) Create a database and import database.sql:
     ~$ mysql -u user -p db_name < database.sql 

3) Configure mysqlconnector.rb with your MySQL parameters

4) Install rubygems, the 'daemons' gem and the ruby-mysql library

5) run it:
     ~$ ruby master.rb start

=== Web App

1) Install RubyGems

2) Install Sinatra and ActiveRecord:
    ~$ sudo gem install sinatra activerecord

3) Configure index.rb with your database values

4) Launch the app:
    ~$ ruby index.rb

5) Open your browser and go to: http://127.0.0.1:4567

== License

This file is part of PostLogSQL.

PostLogSQL is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

PostLogSQL is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PostLogSQL.  If not, see <http://www.gnu.org/licenses/>.
