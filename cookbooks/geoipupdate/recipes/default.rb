#
# Cookbook:: geoipdate
# Recipe:: default
#
# Copyright:: 2020, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt"

license_keys = data_bag_item("geoipupdate", "license-keys")

package "geoip-database" do
  action :purge
end

package "geoip-database-contrib" do
  action :purge
end

package "geoipupdate" do
  action :purge
  only_if { ::File.exist?("/etc/cron.d/geoipupdate") }
end

package "geoipupdate"

template "/etc/GeoIP.conf" do
  source "GeoIP.conf.erb"
  owner "root"
  group "root"
  mode "644"
  variables :license_keys => license_keys
end

execute "geoipupdate" do
  command "geoipupdate"
  user "root"
  group "root"
  not_if { ENV.key?("TEST_KITCHEN") || node[:geoipupdate][:editions].all? { |edition| ::File.exist?("/usr/share/GeoIP/#{edition}.mmdb") } }
end

directory "/var/lib/GeoIP" do
  action :delete
  recursive true
end
