# account.rb
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
file_dir = File.dirname(__FILE__)
require File.join file_dir, "access_token.rb"
require File.join file_dir, "twitter.rb"
require File.join file_dir, "query_cache.rb"

module Troyolo

class Account
  attr_reader :save_path
public
  #----------------------------------------------------------------------------
  def initialize(access, save_path)
    @token = access
    @user = {}
    @save_path = save_path
    @query_cache = QueryCache.new
  end

  #----------------------------------------------------------------------------
  def login
    if not loggedin? 
      @user = @token.get Twitter.account_login_path
    end
  end  

  #----------------------------------------------------------------------------
  def loggedin?
    @user.size > 0
  end

  #----------------------------------------------------------------------------
  def screen_name
    @user["screen_name"]
  end

  #----------------------------------------------------------------------------
  def followers_count
    @user["followers_count"] 
  end

  #----------------------------------------------------------------------------
  def follower_ids(page = -1)
    return [] if not loggedin?
    path = Twitter.follower_ids_query_path
    path.concat "?cursor=#{page}&screen_name=#{@user["screen_name"]}"
    @query_cache.execute @token, :get, path
  end

  #----------------------------------------------------------------------------
  def to_json(options)
    h = FlyingRobots::Obj.to_hash(self).delete_if { |key, value|
      key == "token"
    }
    if options[:pretty] == true
      JSON.pretty_generate h
    else
      JSON.generate h
    end
  end
end

end

