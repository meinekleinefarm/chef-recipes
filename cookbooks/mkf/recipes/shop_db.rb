db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

db_creds = Chef::EncryptedDataBagItem.load("passwords", "mkf_shop_db")

postgresql_database_user db_creds["username"] do
  connection db_connection
  password db_creds["password"]
  action :create
end

postgresql_database "mkf_production" do
  connection db_connection
  owner db_creds["username"]
  action :create
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
end

postgresql_database_user db_creds["username"] do
  connection    db_connection
  database_name 'mkf_production'
  privileges    [:all]
  action        :grant
end


cron 'daily-backup' do
  hour    '2'
  minute  '32'
  user    'rails'
  command 'cd /var/apps && /usr/bin/pg_dump mkf_production -U mkf_production | gzip > /var/apps/mkf_production_`date "+%d_%m_%Y"`.sql.gz'
end
