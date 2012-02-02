require 'typhoeus'
require 'json'
require 'google/api_client'

#register your project with google at https://code.google.com/apis/console/, get the below constants
CLIENT_ID = 'YOUR CLIENT ID'
CLIENT_SECRET = 'YOUR CLIENT SECRET'
REDIRECT_URI = 'http://YOUR_SITE/googleauth' 

#first we send users to this URL:
google_contacts_api_uri = 'https://www.google.com/m8/feeds'
google_calendar_api_uri = 'http://www.google.com/calendar/feeds/default/allcalendars/full'

send_user_to = "https://accounts.google.com/o/oauth2/auth?scope=#{google_contacts_api_uri}+#{google_calendar_api_uri}&response_type=code&redirect_uri=#{REDIRECT_URI}&approval_prompt=force&client_id=#{CLIENT_ID}&hl=en-US&from_login=1&access_type=offline"

#the user approves the request and you get a code in your redirect URI 'http://YOUR_SITE/googleauth?code=YOUR_CODE 
@code = 'YOUR_CODE' #=> get YOUR_CODE at the end of your redirect URI 'http://YOUR_SITE/googleauth?code=YOUR_CODE 

class Auth
  attr_reader :refresh_token , :access_token , :code , :token_expires_time
  
  def initialize args = {}
    args.each do |k,v|
    	instance_variable_set("@#{k}",v) unless v.nil?
    	acquire_tokens_with_code v if k == :code
    end
    acquire_new_access_token unless @refresh_token.nil? #if we don't have a code, make sure we have the latest access_token
  end
  #acquire_tokens_with_code (returns refresh & access token)
  def acquire_tokens_with_code code
    res = Typhoeus::Request.post('https://accounts.google.com/o/oauth2/token ', :params => {
      'code' => @code,
      'client_id' => CLIENT_ID,
      'client_secret' => CLIENT_SECRET,
      'redirect_uri' => REDIRECT_URI,
      'grant_type' => 'authorization_code'
    })
    results = JSON.parse(res.body)
    @access_token = results['access_token']
    @refresh_token = results['refresh_token']
    @token_expires_time = results['expires_in'].to_i + Time.now.to_i
  end
  #acquire_new_access_token 
  def acquire_new_access_token
    res = Typhoeus::Request.post('https://accounts.google.com/o/oauth2/token ', :params => {
      'client_id' => CLIENT_ID,
      'client_secret' => CLIENT_SECRET,
      'refresh_token' => @refresh_token,
      'grant_type' => 'refresh_token'
    })
    results = JSON.parse(res.body)
    @access_token = results['access_token']
    @token_expires_time = results['expires_in'].to_i + Time.now.to_i
  end
end