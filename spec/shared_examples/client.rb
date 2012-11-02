shared_examples_for 'a successful response' do
  it { subject[:success].should be_true }
  it { subject[:bucket_name].should == bucket_name }
end
