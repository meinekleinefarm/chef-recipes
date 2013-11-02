#
# Cookbook Name:: memcached
# Attributes:: default
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['memcached']['memory'] = 256
default['memcached']['port'] = 11211
default['memcached']['listen'] = node[:ipaddress]
default['memcached']['maxconn'] = 1024
case node['platform_family']
when 'suse', 'fedora', 'rhel'
  default['memcached']['user'] = 'memcached'
  default['memcached']['group'] = 'memcached'
when 'debian', 'ubuntu'
  default['memcached']['user'] = 'memcache'
  default['memcached']['group'] = 'memcache'
else
  default['memcached']['user'] = 'nobody'
  default['memcached']['user'] = 'nogroup'
end