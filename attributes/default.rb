# encoding: UTF-8
#
# Cookbook Name:: mysql_tuning
# Attributes:: default
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
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

self.class.send(:include, ::MysqlTuning::CookbookHelpers)

default['mysql_tuning']['system_percentage'] = 100
default['mysql_tuning']['dynamic_configuration'] = false
default['mysql_tuning']['interpolation'] = 'proximal'
default['mysql_tuning']['recipe'] = nil
default['mysql_tuning']['type'] = 'balanced'

default['mysql_tuning']['interpolation_by_variable'] = {}

case node['platform']
when 'fedora'
  default['mysql_tuning']['include_dir'] = '/etc/my.cnf.d'
when 'freebsd'
  default['mysql_tuning']['include_dir'] = '/usr/local/etc/mysql/conf.d'
else
  default['mysql_tuning']['include_dir'] = '/etc/mysql/conf.d'
end

default['mysql_tuning']['mysqld_bin'] =
  case node['platform']
  when 'centos', 'redhat', 'scientific', 'fedora', 'suse', 'amazon'
    if %w(centos).include?(node['platform']) &&
       node['platform_version'].to_i >= 7
      'mysqld'
    else
      '/usr/libexec/mysqld'
    end
  when 'freebsd'
    '/usr/local/libexec/mysqld'
  # when 'debian', 'ubuntu' then
  else
    'mysqld'
  end

default['mysql_tuning']['logging.cnf'] = {
  mysqld: {
    expire_logs_days: 30,
    slow_query_log: 'ON',
    slow_query_log_file: 'slow-query.log'
  }
}

# Calculated from samples
default['mysql_tuning']['tuning.cnf'] = Mash.new
