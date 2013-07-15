db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database_user "mkf_production" do
  connection db_connection
  password "foobar"
  database_name 'mkf_production'
  # privileges [:select,:update,:insert,:delete]
  action :create
end

postgresql_database "mkf_production" do
  connection db_connection
  owner "mkf_production"
  action :create
end
