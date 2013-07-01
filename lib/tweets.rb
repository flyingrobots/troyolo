# tweets.rb
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
frutils = File.expand_path File.join(file_dir, '..', 'deps', 'frutils.git')

require File.join frutils, 'log.rb'
require 'rubygems'
require 'twitter'

module Troyolo

# TODO Configure Twitter API and each Client separately, figure out why none
# of the clients authenticate...

class Tweets
public
  #----------------------------------------------------------------------------
  def self.configure(config)
    @@log.debug "Configuring Twitter with config: ", config
    Twitter.configure { |t| 
      t.consumer_key = config[:consumer_key]
      t.consumer_secret = config[:consumer_secret]
    }
  end

  #----------------------------------------------------------------------------
  def self.create_client(config)
    _create_client config
  end

  #----------------------------------------------------------------------------
  def self.search(query, start_id)
    @@log.info "Searching for tweets '#{query}', since tweet #{start_id}"
    results = Twitter.search(
      query,
      :count => MAX_SEARCH_RESULTS,
      :result_type => "recent",
      :since_id => start_id
    )
    @@log.info "Found #{results.statuses.count} tweets"
    @@log.info "Last tweet id found: #{results.max_id}"
    results
  end

private
  @@log = FlyingRobots::Log.new({
      :name => "Tweets",
      :volume => FlyingRobots::Log::VOLUME_DEBUG
    })

  #----------------------------------------------------------------------------
  def self._create_client(config)
    @@log.debug "Creating new twitter client with config: ", config
    Twitter::Client.new(
      :oauth_token => config[:oauth_token],
      :oauth_token_secret => config[:oauth_secret],
      :endpoint => config[:authorize_url]
    )
  end
end

end
