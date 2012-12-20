class PhpbbUser < ActiveRecord::Base
  def self.table_name() "#{PHPBB_AUTH_FORUM_DATABASE_TABLE_PREFIX}users" end
end
  
  
