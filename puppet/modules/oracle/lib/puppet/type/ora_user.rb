require 'pathname'
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent)
$:.unshift(Pathname.new(__FILE__).dirname.parent.parent.parent.parent + 'easy_type' + 'lib')
require 'easy_type'
require 'orabase/utils/oracle_access'
require 'orabase/utils/title_parser'


module Puppet
  #
  # Create a new type oracle_user. Oracle user, works in conjunction 
  # with the §Resource provider
  #
  newtype(:ora_user) do

    class ::Puppet::Type::Ora_user
      include EasyType
      include ::OraUtils::OracleAccess
      extend ::OraUtils::TitleParser

      desc %q{
        This resource allows you to manage a user in an Oracle database.
      }

      ensurable

      set_command(:sql)

      to_get_raw_resources do
        sql_on_all_database_sids "select * from dba_users"
      end

      on_create do | command_builder |
        statement = password ?  "create user #{username} identified by \"#{password}\""  : "create user #{username}"
        command_builder.add(statement, :sid => sid)
      end

      on_modify do | command_builder |
        command_builder.add("alter user #{username}", :sid => sid)
      end

      on_destroy do | command_builder |
        command_builder.add("drop user #{username} cascade", :sid => sid)
      end


      map_title_to_sid(:username) { /^((@?.*?)?(\@.*?)?)$/}

      parameter :name
      parameter :username
      parameter :sid

      property  :user_id
      parameter :password
      property  :default_tablespace
      property  :temporary_tablespace
      property  :quotas
      property  :grants

      autorequire (:ora_tablespace) {[default_tablespace, temporary_tablespace]}

    end
  end
end
