include_recipe "perl"
cpan_module "DBD::Pg"

%w(
  postgres_bgwriter
  postgres_checkpoints
  postgres_xlog
  postgres_users
  postgres_connections
).each do |plugin_name|
  munin_plugin plugin_name do
    plugin plugin_name
    create_file true
  end
end