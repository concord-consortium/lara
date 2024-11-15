require 'spec_helper'

describe CollectionFilter do
  let(:params)         { {} }
  let(:user_stubs)     { {} }
  let(:klass_stubs)    { {} }
  let(:items)          { double("collection") }
  let(:user)           { mock_model(User, user_stubs) }
  let(:fake_class)     { double("fake AR class", klass_stubs) }

  subject do
    CollectionFilter.new(user, fake_class, params)
  end

  describe "#collection" do
    # TODO: rename :my?
    describe "without :my specified in params" do
      it "should return a sorted public collection" do
        expect(fake_class).to receive(:visible).and_return(items)
        expect(items).to receive(:newest).and_return([1,2,3])
        expect(subject.collection).to be_a_kind_of(Array)
      end
    end

    describe "with :my specified in params" do
      let(:params) { {my: true} }
      it "should return a sorted public collection" do
        expect(fake_class).to receive(:my).and_return(items)
        expect(items).to receive(:newest).and_return([1,2,3])
        expect(subject.collection).to be_a_kind_of(Array)
      end

      describe "also with limit assigned in params" do
        let(:params) { {my: true, limit: 30 }}
        it "should return a sorted public collection" do
          expect(fake_class).to receive(:my).and_return(items)
          expect(items).to receive(:limit).and_return(items)
          expect(items).to receive(:newest).and_return([1,2,3])
          expect(subject.collection).to be_a_kind_of(Array)
        end
      end

      describe "with a nil user" do
        let(:user) { nil }
        it "should return a sorted public collection" do
          expect(fake_class).not_to receive(:my)
          expect(fake_class).to receive(:is_public).and_return(items)
          expect(items).to receive(:newest).and_return([1,2,3])
          expect(subject.collection).to be_a_kind_of(Array)
        end
      end

      describe "with invalid parameters" do
        let(:params) { {my: true, user: 'xx', blarg: 'dfd' }}
        it "should return a sorted public collection" do
          expect(fake_class).to receive(:my).and_return(items)
          expect(items).not_to receive(:user)
          expect(items).not_to receive(:blarg)
          expect(items).to receive(:newest).and_return([1,2,3])
          expect(subject.collection).to be_a_kind_of(Array)
        end
      end

    end

  end
end
