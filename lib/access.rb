# access.rb
# ------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2013 James Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ------------------------------------------------------------------------------
file_dir = File.expand_path File.dirname(__FILE__)
require File.join file_dir, "twitter.rb"

frutils = File.expand_path File.join(file_dir, "..", "deps", "frutils.git")
require File.join frutils, "log.rb"
require File.join frutils, "obj.rb"

require 'rubygems'
require 'oauth'

module Troyolo

class AccessToken
public
  #----------------------------------------------------------------------------
  def initialize(oauth_token, oauth_secret, api_token, api_secret)
    @log = FlyingRobots::Log.new({:name => "AccessToken", :volume => FlyingRobots::Log::VOLUME_DEBUG})
    @oauth_token = oauth_token
    @oauth_secret = oauth_secret
    @api_token = api_token
    @api_secret = api_secret
    @access_token = _create_access_token
  end

  #----------------------------------------------------------------------------
  def get(path, options = {}, *args)
    _request :get, path, options, args
  end

  #----------------------------------------------------------------------------
  def post(path, options = {}, *args)
    _request :post, path, options, args
  end

private
  #----------------------------------------------------------------------------
  def _create_access_token
    oauth_consumer = OAuth::Consumer.new(@api_token, @api_secret, {
      :site => "http://api.twitter.com",
      :scheme => :header
    })
    token_hash = {
      :oauth_token => @oauth_token,
      :oauth_token_secret => @oauth_secret
    }
    OAuth::AccessToken.from_hash oauth_consumer, token_hash
  end

  #----------------------------------------------------------------------------
  def _request(method, path, options = {}, *args)
    url = Twitter.api_url + path
    http_response = @access_token.request(method, url, args) 
    response = FlyingRobots::Obj.to_hash(http_response)
    JSON.parse response['body']
  end

end

end

