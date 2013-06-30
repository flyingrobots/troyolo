# config.rb
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
