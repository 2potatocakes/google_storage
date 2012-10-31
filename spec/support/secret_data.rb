require 'yaml'
require 'erb'

class SecretData
  def initialize
    @config = YAML.load(ERB.new(IO.read('spec/support/google_storage.yml')).result)
  end
  def silence!(&block)
    recursive_silence(@config, &block)
  end
  private
  def recursive_silence(nested_hash, &block)
    nested_hash.each_pair do |key, val|
      case val
      when String
        silence(val, "____SILENCED_#{key}____", &block)
      when Hash
        recursive_silence(val, &block)
      end
    end
  end
  def silence(silence, message, &block)
    block.call silence, message
    block.call URI.escape(silence, '/'), message
  end
end
