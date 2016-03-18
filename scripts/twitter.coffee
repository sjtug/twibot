# Description:
#   Manage  SJTUG's twitter account with hubot
#
# Dependencies:
#   "twitter": "^1.2.5",
#
# Configuration:
#   HUBOT_TWITTER_CONSUMER_KEY
#   HUBOT_TWITTER_CONSUMER_SECRET
#   HUBOT_TWITTER_ACCESS_TOKEN_KEY
#   HUBOT_TWITTER_ACCESS_TOKEN_SECRET
#
# Commands:
#   hubot tweet <message> - Tweet `message` with SJTUG's twitter account
#   hubot dm <user> <message> - Send a direct message to `user` with SJTUG's twitter account
#
# Author:
#   chase

auth =
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET
  access_token_key: process.env.HUBOT_TWITTER_ACCESS_TOKEN_KEY
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET

twitter = new require('twitter')(auth)

module.exports = (robot) ->
  # hubot tweet
  robot.respond /tweet\s+(.*)$/, (msg) ->
    if not robot.auth.hasRole(msg.envelope.user,'manager')
      msg.send "Sorry, @#{msg.envelope.user.name} do not have permission of managing the Twitter account."
      return

    text = msg.match[1].trim()
    if text.length <= 0
      msg.send 'Sorry, you can not post an empty message on Twitter.'
      return
    else if text.length > 140
      msg.send 'Sorry, you can not post a message longer than 140 characters to Twitter.'
      return

    twitter.post 'statuses/update', {status: text},  (error, tweet, response) ->
      if error
        msg.send "Sorry, I failed to post your message. Detail: #{error.message}"
      else
        msg.send ":beer: Great! I have put your message on Twitter! https://twitter.com/statuses/#{tweet.id_str}"

  # hubot DM
  robot.respond /dm\s+(\S+)\s+(.*)$/, (msg) ->
    if not robot.auth.hasRole(msg.envelope.user,'manager')
      msg.send "Sorry, @#{msg.envelope.user.name} do not have permission of managing the Twitter account."
      return
    user = msg.match[1].replace '@', ''
    text = msg.match[2].trim()
    if text.length <= 0
      msg.send "Sorry, you can not send an empty message to #{user} on Twitter."
      return
    twitter.post 'direct_messages/new', {text:text, screen_name:user}, (error, tweet, response) ->
        if error
          msg.send "Sorry, I was unable to send your message. Detail: #{error.message}"
        else
          msg.send ":beer: Great! I have sent your message to @#{user} on Twitter."
