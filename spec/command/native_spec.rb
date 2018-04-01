require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Native do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ native }).should.be.instance_of Command::Native
      end
    end
  end
end

