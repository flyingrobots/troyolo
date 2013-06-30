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

# ------------------------------------------------------------------------------
def load_config
  Troyolo::Configuration.new().configure() { |opts|
      opts.config_filepath = File.join $file_dir, "config", "app.json"
      opts.data_dir = File.join $file_dir, "data"
  }
end

# ------------------------------------------------------------------------------
def load_accounts(account_list, log)
  errors = []
  clients = account_list.collect { |twitter_config|
    begin
      Troyolo::Account.new twitter_config
    rescue => e
      errors << e
      log.info "Bad account config for '#{twitter_config[:username]}'"
      log.info "Unable to authenticate '#{twitter_config[:username]}'"
    end
  }
  errors.each { |e| log.exception e }
end

# ------------------------------------------------------------------------------
def log_lost_followers(account, log)
  saved = account.saved_followers_ids
  current = account.follower_ids
  losses = saved - current
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
FlyingRobots::Application.new(ARGV).run() { |opts|
  log = FlyingRobots::Log.new
	
  config = load_config
  log.debug "config.settings = ", config.settings

  clients = load_accounts config.settings[:twitter_accounts], log
  clients.each { |c| 
    log.info "Account '#{c.username}' is ready"
    log_lost_followers c
    follow_new_followers c
  }
}
