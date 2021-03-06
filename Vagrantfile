# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.

  # set auto_update to false, if do NOT want to check the correct additions
  # version when booting this machine
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true

  # Box basics
  config.vm.box = "chef/ubuntu-12.04"
  config.vm.box_url = "https://vagrantcloud.com/chef/ubuntu-12.04/version/1/provider/virtualbox.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network", :bridge => 'vnic0'

  hostname = `hostname -s`
  config.vm.hostname = "vb-precise64-#{hostname.strip}"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--usb", "off"]
  end

  config.omnibus.chef_version = :latest

  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file opscode-ubuntu-1204.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "init.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path                     = "cookbooks"
    chef.roles_path                         = "roles"
    chef.data_bags_path                     = "data_bags"
    chef.encrypted_data_bag_secret_key_path = "bootstrap/encrypted_data_bag_secret"
    chef.environments_path                  = "environments"
    chef.environment                        = "vagrant"


    chef.add_role("base")
    chef.add_role("memcached_master")
    chef.add_role("mkf_shop_database_server")
    chef.add_role("mkf_shop_application_server")

    # You may also specify custom JSON attributes:
    chef.json = {
                  :mysql => {
                    :server_debian_password => 'foo',
                    :server_root_password   => 'bar',
                    :server_repl_password   => 'foobar'
                  },

                  :postgresql => {
                    :password => {
                      :postgres => "vg"
                    }
                  }
                }
  end


  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/mkf"
  #   chef.validation_key_path = ".chef/mkf-validator.pem"
  #   chef.encrypted_data_bag_secret_key_path = 'bootstrap/encrypted_data_bag_secret'
  #   chef.environment = "vagrant"
  #
  #   chef.add_role("base")
  #   chef.add_role("memcached_master")
  #   chef.add_role("mkf_shop_database_server")
  #   chef.add_role("mkf_shop_application_server")
  #
  #   #
  #   # If you're using the Opscode platform, your validator client is
  #   # ORGNAME-validator, replacing ORGNAME with your organization name.
  #   #
  #
  #   # If you have your own Chef Server, the default validation client name is
  #   # chef-validator, unless you changed the configuration.
  #   #
  #   chef.validation_client_name = "mkf-validator"
  # end
end
