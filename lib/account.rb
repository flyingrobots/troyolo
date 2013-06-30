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
  def initialize(config)
    @client = Troyolo::Tweets.new config
    @filepath = config[:save_filepath]
    @save_data = _from_file File.expand_path(@filepath)
  end

  def username
    @client.username
  end

  def saved_followers_count
    @save_data[:follower_ids].size
  end

  def saved_follower_ids
    @save_data[:follower_ids]
  end

  def followers_count
    @client.followers_count
  end

  def follower_ids
    @client.follower_ids(@client.username)
  end

  def save
    _to_file(@filepath)
  end

private
  
  def _from_file(filepath)
    file_dir = File.expand_path File.dirname(__FILE__)
    relative_path = FlyingRobots::Files.relative_path(file_dir, filepath)
    expanded_path = File.expand_path relative_path
    if File.file? expanded_path
      Oj.load File.read(expanded_path)
    else
      {}
    end
  end

  def _to_file(filepath)
    data = {
      :username => username,
      :follower_ids => follower_ids
    }
    Oj.to_file @filepath, data, :indent => 4
  end

end

end
