# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Author: Kiall Mac Innes <kiall@hp.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

module PasswordsHelper
  def lookup_password(service, user, default=nil)
    sources = node[:passwords][:sources]

    sources.each do |source|
      password = send("lookup_password_#{source}", service, user)

      return password if not password.nil?
    end

    if default.nil?
      Chef::Application.fatal!("Failed to find password for user '#{user}' on service '#{service}'")
    else
      return default
    end
  end

  protected

  def lookup_password_attribute(service, user)
    return node[service]["#{user}_password"]
  rescue Exception
    return nil
  end

  def lookup_password_databag(service, user)
    passwords = data_bag_item('passwords', service)

    return passwords.fetch(user, nil)
  rescue Exception
    return nil
  end

  def lookup_password_edb(service, user)
    passwords = Chef::EncryptedDataBagItem.load('passwords', user)

    return passwords.fetch(user, nil)
  rescue Exception
    return nil
  end
end

class Chef::Recipe
    include PasswordsHelper
end

class Chef::Node
    include PasswordsHelper
end
