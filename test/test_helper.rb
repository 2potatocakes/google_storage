require 'rubygems'
require 'fileutils'
require 'test/unit'
require 'vcr'
require 'mocha'


VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :fakeweb
end

module GSTestHelpers


end

