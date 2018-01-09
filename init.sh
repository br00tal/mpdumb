#!/bin/sh

dockerize -template config.json.tmpl:config.json
./mpdumb.rb
