require 'yaml'
require 'erb'

class SecretData

  def initialize(gs_yml_path = "spec/support/google_storage.yml")
    @config = YAML.load(ERB.new(IO.read(gs_yml_path)).result)
  end

  def silence!(&block)
    recursive_silence(@config, &block)
  end

  private

  def recursive_silence(nested_hash, &block)
    nested_hash.each_pair do |key, val|
      case val
      #The following was still leaving google-project-id's in the yml fixtures
      #during requests to gs, so added Bignum's and Integer's as well
      when String, Bignum, Integer
        silence(val, "____SILENCED_#{key}____", &block)
      when Hash
        recursive_silence(val, &block)
      end
    end
  end

  def silence(silence, message, &block)
    block.call silence, message
    block.call URI.escape(silence.to_s, '/'), message
  end
end
