require 'rubygems'
require 'sinatra'
require 'active_record'

$LIMIT = 10

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :encoding => 'utf8',
  :database => 'postlogsql',
  :username => 'root',
  :password => '',
  :host => 'localhost'
)

class Deliver < ActiveRecord::Base
  set_table_name 'postfix_logs'
end

get '/delivers' do
  @limit = $LIMIT
  @delivers_count = Deliver.count(:all)
  @delivers_limit = @delivers_count/@limit
  @delivers = Deliver.find(:all, :limit => @limit, :order => "id DESC")
  erb :delivers
end

get '/delivers/:page' do
  @limit = $LIMIT
  @delivers_count = Deliver.count(:all)
  @delivers_limit = @delivers_count/@limit
  @page = params[:page].to_i > @delivers_limit ? @delivers_limit : params[:page].to_i
  @delivers = Deliver.find(:all, :limit => @limit, :offset => @page*@limit, :order => "id DESC")
  erb :delivers
end

post '/delivers/filter' do
  @limit = $LIMIT
  @delivers_count = Deliver.count(:all)
  @delivers_limit = @delivers_count/@limit
  @page = params[:page].to_i > @delivers_limit ? @delivers_limit : params[:page].to_i
  filter_type = params[:filter_type] == 'message_id' ? 'message_id' : 'status'
  filter_value = "%#{params[:filter_value]}%"
  @delivers = Deliver.find(:all, :conditions => ["#{params[:filter_type]} LIKE ?", filter_value], :limit => @limit, :offset => @page*@limit, :order => "id DESC")
  erb :filtered_delivers
end

get '/stats' do
  @stats = {}
  @stats[:mailers] = {}
  # Emails sent by each mailer
  mailers = Deliver.find(:all, :group => :hostname)
  mailers.each do |mailer| 
    @stats[:mailers][mailer.hostname] = {}
    sent = Deliver.count(:all, :conditions => { :hostname => mailer.hostname, :delivery_success => "yes" })
    failed = Deliver.count(:all, :conditions => { :hostname => mailer.hostname, :delivery_success => "no" })
    @stats[:mailers][mailer.hostname][:sent] = sent
    @stats[:mailers][mailer.hostname][:failed] = failed
  end
  # Deferred emails
  deferred = Deliver.find_by_sql("select count(*) as num, status from postfix_logs where delivery_success='no' and status LIKE '%deferred%' group by status order by num DESC;")
  @stats[:deferred] = []
  deferred.each do |mail|
    hash = {}
    hash[:num] = mail.num
    hash[:message] = mail.status
    @stats[:deferred] << hash
  end
  # Bounced emails
  bounced = Deliver.find_by_sql("select count(*) as num, status from postfix_logs where delivery_success='no' and status LIKE '%bounced%' group by status order by num DESC;")
  @stats[:bounced] = []
  bounced.each do |mail|
    hash = {}
    hash[:num] = mail.num
    hash[:message] = mail.status
    @stats[:bounced] << hash
  end
  # Codes
  codes = Deliver.find_by_sql("select count(*) as num, p.status_code as code, c.descrizione as descr from postfix_logs p JOIN Codice_Errore c ON p.status_code=c.codice where p.delivery_success='no' and p.status_code <> 250 and p.status_code <> 0 group by p.status_code order by num DESC;")
  @stats[:codes] = []
  codes.each do |code|
    hash = {}
    hash[:num] = code.num
    hash[:descr] = code.descr
    hash[:code] = code.code
    @stats[:codes] << hash
  end
  
  # Render
  erb :stats
end