#!/usr/bin/env ruby

require 'rubygems'
require 'twitter'
require 'oj'

CONFIG_FILE = "./troyolo_config.json"
SAVE_FILE = "./troyolo_save.json"

$config = Oj.load_file(File.expand_path(CONFIG_FILE))
$saveData = Oj.load_file(File.expand_path(SAVE_FILE))

$twitterConfig = $config["twitter_config"]
$dropURLs = $config["drops"]
$quips = $config["quips"]
$ignoreList = $config["twitter_users_to_ignore"]
$searchSize = $config["search_size"]

puts "AUTOMATED DROP DELIVERY"
puts "Upcoming queries..."
p $saveData

#-------------------------------------------------------------------------------
def searchPublicTweets(query, lastTweetIdSeenForThisQuery)
	puts ""
	puts "Last tweet id seen for query (#{query}): #{lastTweetIdSeenForThisQuery}"
	searchResults = Twitter.search(
			"#troyolo", 
			:count => $searchSize, 
			:result_type => "recent",
			:since_id => lastTweetIdSeenForThisQuery
		)
	puts "Found #{searchResults.statuses.count} new tweets."
	puts "Last tweet found: #{searchResults.max_id}"
	return searchResults
end

#-------------------------------------------------------------------------------
def deliverTheDrop(tweet)
	if $ignoreList.index(tweet.from_user)
		puts "Ignoring tweet from user: #{tweet.from_user}"
	else
		drop = $dropURLs[rand($dropURLs.count)]
		quip = $quips[rand($quips.count)]
		puts "#{tweet.from_user}: #{tweet.text}"
		puts "\tSending drop (#{drop}) to #{tweet.from_user} in response to (#{tweet.id})"
		dropTweet = "@#{tweet.from_user} #{quip} #{drop} [secret code: #{rand(tweet.id)}]"
		puts "\t#{dropTweet}"
		Twitter.update("#{dropTweet}", :in_reply_to_status_id => tweet.id)
	end
end

#-------------------------------------------------------------------------------
def searchAndDeliver(query)
	lastTweetIdSeenForThisQuery = $saveData[query]
	lastTweetIdSeenForThisQuery = 0 if lastTweetIdSeenForThisQuery.nil?
	searchResults = searchPublicTweets(query, lastTweetIdSeenForThisQuery)
	searchResults.statuses.each() { |tweet|	
		deliverTheDrop(tweet)
	}
	$saveData[query] = searchResults.max_id
end

#///////////////////////////////////////////////////////////////////////////////
# deliver the drop
#///////////////////////////////////////////////////////////////////////////////

# login to twitter
Twitter.configure do |t|
	t.consumer_key = $twitterConfig["consumer_key"]
	t.consumer_secret = $twitterConfig["consumer_secret"]
	t.oauth_token = $twitterConfig["oauth_token"]
	t.oauth_token_secret = $twitterConfig["oauth_token_secret"]
end

# search and deliver
searches = $config["searches"]
searches.each() { |query|
	searchAndDeliver(query)
}

# save query info
Oj.to_file(SAVE_FILE, $saveData, :indent => 4)
