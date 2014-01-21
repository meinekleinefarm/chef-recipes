#
# Cookbook Name:: duplicity
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "duplicity"
package "ncftp"

backup_credentials = Chef::EncryptedDataBagItem.load("passwords", "duplicity")

template 'backup' do
  path     "/usr/local/sbin/backup.sh"
  source   'backup.tmpl'
  owner    'root'
  group    'root'
  mode     '0700'
  backup   false
  variables({
    host:     backup_credentials["host"],
    user:     backup_credentials["user"],
    password: backup_credentials["password"]
  })
end

template 'restore' do
  path     "/usr/local/sbin/restore.sh"
  source   'restore.tmpl'
  owner    'root'
  group    'root'
  mode     '0700'
  backup   false
  variables({
    host:     backup_credentials["host"],
    user:     backup_credentials["user"],
    password: backup_credentials["password"]
  })
end

cron 'backup' do
  command '/usr/local/sbin/backup.sh'
  user    'root'
  minute  '4'
  hour    '4'
end