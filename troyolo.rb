#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'oj'

CONFIG_FILE = "./troyolo_config.json"

puts "AUTOMATED TROYOLO DROP"

#///////////////////////////////////////////////////////////////////////////////
# open and read config file
#///////////////////////////////////////////////////////////////////////////////

config = Oj.load_file(File.expand_path(CONFIG_FILE))

#///////////////////////////////////////////////////////////////////////////////
# authenticate w/twitter
#///////////////////////////////////////////////////////////////////////////////

twitterConfig = config["twitter_config"]

Twitter.configure do |t|
	t.consumer_key = twitterConfig["consumer_key"]
	t.consumer_secret = twitterConfig["consumer_secret"]
	t.oauth_token = twitterConfig["oauth_token"]
	t.oauth_token_secret = twitterConfig["oauth_token_secret"]
end

#///////////////////////////////////////////////////////////////////////////////
# search for tweets containing #troyolo
#///////////////////////////////////////////////////////////////////////////////

puts "Last known tweet id: #{config["last_search_result_id"]}"

searchResults = Twitter.search(
		"#troyolo", 
		:count => config["max_drops_per_delivery"], 
		:result_type => "recent",
		:since_id => config["last_search_result_id"]
	)

puts "Found #{searchResults.statuses.count} tweets."

#///////////////////////////////////////////////////////////////////////////////
# deliver the drop in response to each search result
#///////////////////////////////////////////////////////////////////////////////

dropURLs = config["drops"]
quips = config["quips"]
searchResults.statuses.each() { |tweet|
	drop = dropURLs[rand(dropURLs.count)]
	quip = quips[rand(quips.count)]
	puts "#{tweet.from_user}: #{tweet.text}"
	puts "\tSending drop (#{drop}) to #{tweet.from_user} in response to (#{tweet.id})"
	dropTweet = "@#{tweet.from_user} #{quip} #{drop} [secret code: #{rand(tweet.id)}]"
	puts "\t#{dropTweet}"
	Twitter.update("#{dropTweet}", :in_reply_to_status_id => tweet.id)
}

puts "Last tweet found: #{searchResults.max_id}"
config["last_search_result_id"] = searchResults.max_id
Oj.to_file(CONFIG_FILE, config, :pretty => true)
