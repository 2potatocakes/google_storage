require 'spec_helper'

describe GoogleStorage::Client do

  subject { GoogleStorage::Client }

  context ':config_yml => nil' do
    it { expect { subject.new }.to raise_error(
      RuntimeError, /Can't find a google_storage.yml file to initialise with/
    )}
  end

  context 'invalid :config_yml' do
    it { File.directory?('spec/support').should be_true }
    it { expect { subject.new :config_yml => '/spec/support' }.to raise_error(
      RuntimeError, /Can't find a google_storage.yml file to initialise with/
    )}

    it { File.exists?('spec/support/empty_config.yml').should be_true }
    it { expect { 
        subject.new :config_yml => 'spec/support/bad_config.yml' 
      }.to raise_error( 
        RuntimeError, /Can't find a google_storage.yml file to initialise with/
      )
    }
  end

  context 'valid :config_yml' do
    it { File.exists?('spec/support/google_storage.yml').should be_true }
    it { expect { 
        subject.new(:config_yml => 'spec/support/google_storage.yml')
      }.to_not raise_error
    }
  end

end
