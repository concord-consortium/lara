require 'spec_helper'

describe CollectionFilter do
  let(:params)         { {} }
  let(:user_stubs)     { {} }
  let(:klass_stubs)    { {} }
  let(:items)          { mock("collection") }
  let(:user)           { mock_model(User, user_stubs) }
  let(:fake_class)     { mock("fake AR class", klass_stubs) }

  subject do
    CollectionFilter.new(user, fake_class, params)
  end

  describe "#collection" do
    # TODO: rename :my?
    describe "without :my specified in params" do
      it "should return a sorted public collection" do
        fake_class.should_receive(:visible).and_return(items)
        items.should_receive(:newest).and_return([1,2,3])
        subject.collection.should be_a_kind_of(Array)
      end
    end

    describe "with :my specified in params" do
      let(:params) { {:my => true} }
      it "should return a sorted public collection" do
        fake_class.should_receive(:my).and_return(items)
        items.should_receive(:newest).and_return([1,2,3])
        subject.collection.should be_a_kind_of(Array)
      end

      describe "also with limit assigned in params" do
        let(:params) { {:my => true, :limit => 30 }}
        it "should return a sorted public collection" do
          fake_class.should_receive(:my).and_return(items)
          items.should_receive(:limit).and_return(items)
          items.should_receive(:newest).and_return([1,2,3])
          subject.collection.should be_a_kind_of(Array)
        end
      end

      describe "with invalid parameters" do
        let(:params) { {:my => true, :user => 'xx', :blarg => 'dfd' }}
        it "should return a sorted public collection" do
          fake_class.should_receive(:my).and_return(items)
          items.should_not_receive(:user)
          items.should_not_receive(:blarg)
          items.should_receive(:newest).and_return([1,2,3])
          subject.collection.should be_a_kind_of(Array)
        end
      end

    end

  end
end