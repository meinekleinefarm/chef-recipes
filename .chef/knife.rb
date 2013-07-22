current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "meinekleinefarm"
client_key               "#{current_dir}/meinekleinefarm.pem"
validation_client_name   "mkf-validator"
validation_key           "#{current_dir}/mkf-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/mkf"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
encrypted_data_bag_secret "#{current_dir}/../bootstrap/encrypted_data_bag_secret"