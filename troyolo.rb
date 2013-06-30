#!/usr/bin/env ruby

# troyolo.rb
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

$file_dir = File.expand_path File.dirname(__FILE__)

frutils = File.join $file_dir, 'deps', 'frutils.git'
require File.join frutils, 'app.rb'
require File.join frutils, 'log.rb'

lib = File.join $file_dir, 'lib'
require File.join lib, 'tweets.rb'
require File.join lib, 'config.rb'
require File.join lib, 'account.rb'

require 'rubygems'
require 'oj'

# ------------------------------------------------------------------------------
def args_config
  args_filepath = File.join $file_dir, 'config', 'args.json'
  Oj.load File.read(args_filepath), :symbol_keys => true
end

# ------------------------------------------------------------------------------
def load_config(config_filepath, data_dir)
  Troyolo::Configuration.new().configure() { |opts|      
    opts.config_filepath = File.expand_path config_filepath
    opts.data_dir = File.expand_path data_dir
  }
end

# ------------------------------------------------------------------------------
def load_accounts(account_list, log)
  errors = []
  clients = account_list.collect { |twitter_config|
    account_filepath = File.expand_path File.join($file_dir, twitter_config)
    log.debug "Loading account config file '#{account_filepath}'"
    begin
      account_config = Oj.load File.read(account_filepath), :symbol_keys => true
      log.info "Logging in as '#{account_config[:username]}'..."
      Troyolo::Account.new account_config
    rescue => e
      errors << e
      log.warn "Bad account config: ", account_filepath
    end
  }
  errors.each { |e| log.exception e }
  clients
end

# ------------------------------------------------------------------------------
def log_lost_followers(account, log)
  losses = account.saved_follower_ids - account.follower_ids
  log.info("Lost #{losses.size} followers: ", losses) if losses.size > 0
end

# ------------------------------------------------------------------------------
def follow_new_followers(account, min_followers)
  old_count = account.saved_followers_count
  new_count = account.followers_count
  if new_count > old_count
    new_followers = current - saved
    # TODO finish this
  end
end

# ------------------------------------------------------------------------------
FlyingRobots::Application.new(ARGV, args_config()).run() { |opts|
  log = FlyingRobots::Log.new :volume => FlyingRobots::Log::VOLUME_DEBUG
  
  config = load_config opts[:config], opts[:data]
  
  account_files = config.settings[:twitter_accounts]
  clients = load_accounts(account_files, log).select { |c| c != nil }
  log.info "#{clients.size} account(s) have been configured."
  
  # clients.each { |c| 
  #   log_lost_followers c, log
  #   follow_new_followers c, 500
  # }
}
