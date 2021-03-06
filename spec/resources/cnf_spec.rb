# encoding: UTF-8
#
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

require 'spec_helper'
require 'mysql_interpolator'

describe 'mysql_tuning_cnf resource' do
  let(:my_shell_out) { instance_double('Mixlib::ShellOut') }
  let(:my_version_stdout) do
    'mysql  Ver 14.12 Distrib 5.0.95, for redhat-linux-gnu (x86_64) using '\
    'readline 5.1'
  end
  before do
    allow(Mixlib::ShellOut).to receive(:new)
      .with('mysqld --version').and_return(my_shell_out)
    allow(my_shell_out).to receive(:run_command).and_return(my_shell_out)
    allow(my_shell_out).to receive(:error!)
    allow(my_shell_out).to receive(:stdout).and_return(my_version_stdout)
  end

  def node_setup(node, attrs)
    node.set['mysql_tuning']['recipe'] = 'mysql::server'
    node.automatic['memory']['total'] = system_memory(512 * MB)
    attrs.each do |k, v|
      node.set['mysql_tuning'][k] = v
    end
  end

  def chef_run(attrs = {})
    runner = ChefSpec::SoloRunner.new(
        step_into: %w(mysql_tuning mysql_tuning_cnf)
    ) do |node|
      node_setup(node, attrs)
    end
    runner.converge('mysql_tuning::default')
  end

  def template(name, attrs = {})
    chef_run(attrs).template(name)
  end

  %w(tuning.cnf logging.cnf).each do |cnf|
    path = "/etc/mysql/conf.d/#{cnf}"

    context cnf do

      it 'should create the file with template' do
        expect(chef_run).to create_template(path)
      end

      it 'should create template with the correct properties' do
        expect(chef_run).to create_template(path)
          .with_cookbook('mysql_tuning')
          .with_owner('mysql')
          .with_group('mysql')
          .with_source('mysql.cnf.erb')
      end

      it 'should notify mysql by default' do
        expect(template(path)).to notify('mysql_service[default]')
      end

      # TODO: dynamic conf tests, cannot stub chef library methods

    end # context cnf

  end # cnf.each

end # describe mysql_tuning resource
