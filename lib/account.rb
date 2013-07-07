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
file_dir = File.expand_path File.dirname(__FILE__)
require File.join file_dir, "access.rb"
require File.join file_dir, "twitter.rb"

frutils = File.expand_path File.join(file_dir, "..", "deps", "frutils.git")
require File.join frutils, "log.rb"

module Troyolo

class Account
public
  #----------------------------------------------------------------------------
  def initialize(access, save_path)
    @access = access
    @user = {}
    @save_path = save_path
    @cached_follower_ids = {
      :ids => [],
      :page => -2 # -1 means 'first page', so use -2 as uninitialized value
    }
  end

  #----------------------------------------------------------------------------
  def login
    if not loggedin? 
      @user = @access.get Twitter.account_login_path
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
    last_page = @cached_follower_ids[:page]
    if last_page != page
      path = Twitter.follower_ids_query_path
      path.concat "?cursor=#{page}&screen_name=#{@user["screen_name"]}"
      @cached_follower_ids[:ids] = @access.get(path)["ids"]
      @cached_follower_ids[:page] = page
    end
    @cached_follower_ids[:ids]
  end

end

end

