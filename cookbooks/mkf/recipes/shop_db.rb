db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

db_creds = Chef::EncryptedDataBagItem.load("passwords", "mkf_shop_db")

postgresql_database_user "mkf_production" do
  connection db_connection
  password db_creds["password"]
  database_name 'mkf_production'
  # privileges [:select,:update,:insert,:delete]
  action :create
end

postgresql_database "mkf_production" do
  connection db_connection
  owner "mkf_production"
  action :create
end
