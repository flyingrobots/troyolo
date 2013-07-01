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
require File.join file_dir, 'tweets.rb'

frutils_dir = File.expand_path File.join(file_dir, '..', 'deps', 'frutils.git')
require File.join frutils_dir, 'files.rb'

require 'rubygems'
require 'oj'

module Troyolo

class Account
public
  #----------------------------------------------------------------------------
  def initialize(config)
    @client = Troyolo::Tweets.create_client config
    @filepath = File.expand_path config[:save_filepath]
    @save = _from_file @filepath
  end

  #----------------------------------------------------------------------------
  def username
    @client.username
  end

  #----------------------------------------------------------------------------
  def saved_followers_count
    @save[:follower_ids].size
  end

  #----------------------------------------------------------------------------
  def saved_follower_ids
    @save[:follower_ids]
  end

  #----------------------------------------------------------------------------
  def followers_count
    @client.followers_count
  end

  #----------------------------------------------------------------------------
  def follower_ids
    @client.follower_ids
  end

  #----------------------------------------------------------------------------
  def save
    _to_file(@filepath)
  end

  #----------------------------------------------------------------------------
  def tweet(message)
    @log.info "Tweeting '#{message}'"
    @client.update(message)
  end

  #----------------------------------------------------------------------------
  def reply(to_tweet, username, response)
    @log.info "Responding to tweet '#{to_tweet}"
    @client.update(
      "@#{username} #{response}}", 
      :in_reply_to_status_id => to_tweet
    )
  end

  #----------------------------------------------------------------------------
  def followers_count
    @client.followers_count
  end

  #----------------------------------------------------------------------------
  def user_follower_ids(username)
    Twitter.follower_ids(username)
  end

private
  
  #----------------------------------------------------------------------------
  def _from_file(filepath)
    file_dir = File.expand_path File.dirname(__FILE__)
    relative_path = FlyingRobots::Files.relative_path(file_dir, filepath)
    expanded_path = File.expand_path relative_path
    if File.file? expanded_path
      Oj.load File.read(expanded_path)
    else
      _defaults
    end
  end

  #----------------------------------------------------------------------------
  def _to_file(filepath)
    data = {
      :username => @client.username,
      :follower_ids => @client.follower_ids
    }
    Oj.to_file @filepath, data, :indent => 4
  end

  #----------------------------------------------------------------------------
  def _defaults
    {
      :username => @client.username,
      :follower_ids => []
    }
  end

end

end
