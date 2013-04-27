require 'sucker_punch'
require 'fileutils'

Dir[File.dirname(__FILE__) + '/blastcat/*.rb'].each do |file|
  require file
end

module Blastcat
  def self.logger
    @logger ||= setup_logger
  end

  def self.setup_logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.formatter = proc do |severity, datetime, progname, msg|
      if %w(DEBUG INFO).include?(severity.to_s)
        "----> #{msg}\n"
      else
        "====> #{msg}\n"
      end
    end
    logger
  end
end

SuckerPunch.logger = Blastcat.logger
