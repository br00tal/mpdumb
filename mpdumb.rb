#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cinch'
require 'json'
require 'ruby-mpd'

config_file = 'config.json'
config = JSON.parse(File.read(config_file))

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = config['bot_nick']
    c.user = config['bot_user']
    if config['sasl_username']
      c.sasl.username = config['sasl_username']
      c.sasl.password = config['sasl_password']
    end
    c.server = config['server']
    c.port = config['port']
    c.ssl.use = config['ssl']
    c.channels = config['channels']
  end

  chan = config['channels'].first

  line = if config['user_notify']
           "User: #{config['irc_user']} | Playing: %s by %s from %s [%s]"
         else
           'Playing: %s by %s from %s [%s]'
         end

  mpd = MPD.new config['mpd_server'], config['mpd_port']
  mpd.connect

  current_song = nil
  on :connect do
    User(config['irc_user']).monitor
    loop do
      if mpd.playing?
        song = mpd.current_song
        unless current_song == song
          if User(config['irc_user']).online?
            post = Format(:italic, line % [
              Format(:bold, song.title),
              Format(:bold, song.artist),
              Format(:bold, song.album),
              Format(:bold, song.length)
            ])
            Channel(chan).send post
          end
          current_song = song
        end
      end
      sleep 2
    end
  end
end

bot.start
