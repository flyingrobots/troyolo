# cached_query.rb
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
file_dir = File.dirname __FILE__
frutils = File.expand_path File.join(file_dir, "..", "deps", "frutils.git")
require File.join frutils, "log.rb"

module Troyolo

class CachedQuery
  attr_reader :result

  #----------------------------------------------------------------------------
  def initialize
    @path = ""
    @result = nil
    @timeout = 0
    @log = FlyingRobots::Log.new({
      :name => "CachedQuery",
      :volume => FlyingRobots::Log::VOLUME_DEBUG
    });
  end

  #----------------------------------------------------------------------------
  def execute(token, method, path, *args)
    if @path != path or @timeout < Time.now
      @log.info "http request: #{method} #{path}"
      case method
      when :get
        @result = token.get(path, args)
      when :post
        @result = token.post(path, args)
      else
        raise "Unknown request method '#{method}'"
      end
      @path = path
      @timeout = Time.now + 60 * 45 # 45 minutes
    end
    @result
  end

end

end

