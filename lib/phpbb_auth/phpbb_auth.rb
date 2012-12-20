PHPBB_AUTH_FORUM_DATABASE_TABLE_PREFIX = 'phpbb_'
PHPBB_AUTH_COOKIE_NAME = "phpbb3_7uah4"
PHPBB_AUTH_LOCAL_USER_MODEL_NAME = "User" #this is the name of the model that you will use to store information about users in your rails app
PHPBB_AUTH_REMOTE_REMOTE_IDENTIFIER = 'user_email' #I use email to identify somebody, you may want to use the username instead
PHPBB_AUTH_REMOTE_LOCAL_IDENTIFIER = 'email' #this is the name of a field on your local user model that will be used to lookup the value of remote identifier.
PHPBB_AUTH_COLUMNS_TO_DUPLICATE = {:user_website => :website} #specify any additional fields that you would like copying to your local user model 
module PhpbbAuth  
  def current_user
    unless cookies["#{PHPBB_AUTH_COOKIE_NAME}_sid"].nil?
      @phpbb_session = PhpbbSession.find_by_session_id(cookies["#{PHPBB_AUTH_COOKIE_NAME}_sid"])
      unless @phpbb_session.nil? || !@phpbb_session.logged_in?
        local_user = eval(PHPBB_AUTH_LOCAL_USER_MODEL_NAME).find(:first, :conditions => {PHPBB_AUTH_REMOTE_LOCAL_IDENTIFIER => @phpbb_session.phpbb_user.send(PHPBB_AUTH_REMOTE_REMOTE_IDENTIFIER)})       
        if !local_user
          # We don't have the user registered in the local database, lets create them
          local_user = eval(PHPBB_AUTH_LOCAL_USER_MODEL_NAME).new(PHPBB_AUTH_REMOTE_LOCAL_IDENTIFIER => @phpbb_session.phpbb_user.send(PHPBB_AUTH_REMOTE_REMOTE_IDENTIFIER))
          unless PHPBB_AUTH_COLUMNS_TO_DUPLICATE.nil?
            PHPBB_AUTH_COLUMNS_TO_DUPLICATE.each do |remote_name, local_name|
              local_user.send("#{local_name}=", @phpbb_session.phpbb_user.send(remote_name))
            end
          end
          local_user.save!
        end
        return local_user
      end
    end
  end
end
