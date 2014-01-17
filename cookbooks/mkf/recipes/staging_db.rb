db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

db_creds = Chef::EncryptedDataBagItem.load("passwords", "mkf_staging_db")

postgresql_database_user "mkf_staging" do
  connection db_connection
  password db_creds["password"]
  database_name 'mkf_staging'
  # privileges [:select,:update,:insert,:delete]
  action :create
end

postgresql_database "mkf_staging" do
  connection db_connection
  owner "mkf_staging"
  action :create
end
