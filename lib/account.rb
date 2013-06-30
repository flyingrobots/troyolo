file_dir = File.expand_path File.dirame(__FILE__)
require File.join file_dir, 'tweets.rb'

require 'rubygems'
require 'oj'

module Troyolo

class Account
public
  def initialize(config)
    @client = Troyolo::Tweets.new config
    @filepath = config[:save_filepath]
    @save_data = _from_file(@filepath)
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
    Oj.load filepath
  rescue => e
    raise "Account file '#{filepath}' is not a valid JSON filepath"
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
