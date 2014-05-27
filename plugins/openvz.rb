#
# Copyright 2014, Treehouse Island Inc.
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

Ohai.plugin(:OpenVirtuozzo) do
  depends 'cpu'
  depends 'memory'
  provides 'cpu/total', 'memory/total'
  provides 'ipaddress'

  def openvz?
    ::File.exist?('/proc/vz')
  end

  def openvz_host?
    openvz? && ::File.exist?('/proc/bc/0')
  end

  collect_data(:linux) do
    if openvz? && !openvz_host?
      if openvz_metadata = hint?('openvz')
        cpu['total'] = openvz_metadata['cpu']['total']
        memory['total'] = openvz_metadata['memory']['total']
      end

      network['interfaces'].each do |nic, attrs|
        next unless nic =~ /(venet|veth)/
        attrs['addresses'].each do |addr, params|
          ipaddress addr if addr !~ /^127/ && params['family'] == 'inet'
        end
      end
    end
  end
end
