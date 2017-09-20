#
# Cookbook Name:: atop
# Recipe:: default
#
# Copyright 2017, Keyan Pishdadian
#

package 'atop' do
  action node['atop']['action']
  version node['atop']['version']
end

if platform_family?('rhel')
  conf_file_location = '/etc/sysconfig/atop'
  template_source = 'atop-rhel.erb'
elsif platform_family?('debian')
  conf_file_location = '/etc/default/atop'
  template_source = 'atop-debian.erb'
else
  Chef::Application.fatal!('Unsupported operating system', 1)
end

template conf_file_location do
  action :create
  source template_source
  mode '0644'
  variables(
    logpath: node['atop']['logpath'],
    interval: node['atop']['interval']
  )
  notifies :restart, "service[atop]", :delayed
end

service 'atop' do
  supports start: true,
           stop: true,
           status: true,
           restart: true
  action [:enable, :start]
end

cron 'atop log cleanup' do
  time :daily
  command 'ls -t /var/log/atop/atop_* | tail -n +15 | xargs rm -f'
end
