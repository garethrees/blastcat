ENV['ENTREZ_EMAIL'] = 'test@example.com'

require 'bundler'
Bundler.require

require './lib/blastcat'

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

run Blastcat::Server
