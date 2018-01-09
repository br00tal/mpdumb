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
            post = Format(:italic,
              'User: %s | Playing: %s by %s [%s]' % [
                Format(:bold, User(config['irc_user']).nick),
                Format(:bold, song.title),
                Format(:bold, song.artist),
                Format(:bold, song.length)
              ]
            )
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
