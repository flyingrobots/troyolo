require 'rubygems'
require 'oj'

module Troyolo

class Configuration
  attr_accessor :config_filepath, :data_dir
  attr_reader :settings

public
  #----------------------------------------------------------------------------
  def initialize
    @config_filepath = ""
    @data_dir = ""
    @settings = {}
  end

  #----------------------------------------------------------------------------
  def configure(&block)
    yield self
    _validate_config
    @settings = _parse_json @config_filepath
    self
  end

private
  #----------------------------------------------------------------------------
  def _validate_config
    if not File.directory? @data_dir
      raise "Data directory '#{@data_dir}' is not a valid directory"
    end
  end

  #----------------------------------------------------------------------------
  def _parse_json(filepath)
    Oj.load filepath
  rescue => e
    raise "Invalid config file '#{filepath}'"
  end
end

end
