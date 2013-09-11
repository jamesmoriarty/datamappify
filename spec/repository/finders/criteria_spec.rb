require 'spec_helper'

shared_examples_for "finders" do |data_provider|
  include_context "user repository for finders", data_provider

  context "#{data_provider}" do
    before do
      user_repository.save!(User.new(:last_name => 'Batman', :first_name => 'AA', :driver_license => 'ARKHAMCITY'))
      user_repository.save!(User.new(:last_name => 'Ironman', :first_name => 'AA', :driver_license => 'NEWYORKCITY'))
      user_repository.save!(User.new(:last_name => 'Superman', :first_name => 'AA', :driver_license => 'MELBOURNE'))
      user_repository.save!(User.new(:last_name => 'Superman', :first_name => 'BB', :driver_license => 'SHANGHAI'))
      user_repository.save!(User.new(:last_name => 'Superman', :first_name => 'CC', :driver_license => 'NEWYORKCITY'))
    end

    describe "issue #22" do
      subject { "SuperUserRepository#{data_provider}".constantize.criteria(:where => { :id => 1 }, :match => { :first_name => "" }, :order => { :id => :desc }) }
      its(:class) { should eq Array }
    end

    [
      { :where => { :last_name => 'Superman' }, :limit => 2, :order => { :last_name => :asc, :first_name => :desc } },
      { :order => { :last_name => :asc, :first_name => :desc }, :limit => 2, :where => { :last_name => 'Superman' } },
    ].each_with_index do |criteria, index|
      describe "#criteria example #{index+1}" do
        let(:records) { user_repository.criteria(criteria) }
        subject       { records }

        it { should have(2).user }

        context "record" do
          subject { records.first }

          its(:first_name) { should == 'CC' }
        end
      end
    end
  end
end

describe Datamappify::Repository do
  DATA_PROVIDERS.each do |data_provider|
    it_behaves_like "finders", data_provider
  end
end
