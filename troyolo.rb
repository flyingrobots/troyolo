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
require File.join lib, 'config.rb'
require File.join lib, 'access.rb'
require File.join lib, 'account.rb'

require 'rubygems'
require 'json'

# ------------------------------------------------------------------------------
def args_config
  args_filepath = File.join $file_dir, 'config', 'args.json'
  JSON.parse File.read(args_filepath), {:symbolize_names => true}
end

# ------------------------------------------------------------------------------
def account_from_file(filepath, app)
  settings = JSON.parse File.read(filepath)
  access = Troyolo::AccessToken.new(
    settings["oauth_token"],
    settings["oauth_secret"],
    app["consumer_key"],
    app["consumer_secret"]
  )
  Troyolo::Account.new access, settings["save_filepath"]
end

# ------------------------------------------------------------------------------
FlyingRobots::Application.new(ARGV, args_config()).run() { |opts|
  log = FlyingRobots::Log.new :volume => FlyingRobots::Log::VOLUME_DEBUG
  
  # load application config
  config = JSON.parse File.read(opts[:config])

  # authenticate each account
  users = []
  config["twitter_accounts"].each { |filepath|
    a = account_from_file(filepath, config["twitter_app"])
    a.login
    users << a if a.loggedin?
  }

  # display followers info
  log.info "Logged in count:", users.size
  log.info "---------------------------------------"
  users.each { |u| 
    #log.pretty FlyingRobots::Log::VOLUME_INFO, u.user 
    log.info "Screen name: #{u.screen_name}"
    log.info "Followers count: #{u.followers_count}"
    log.info "Follower ids:"
    log.pretty FlyingRobots::Log::VOLUME_INFO, u.follower_ids
  }
}

