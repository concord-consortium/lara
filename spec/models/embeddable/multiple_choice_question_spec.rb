require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoice do
  before(:each) do
    @page = FactoryGirl.create(:interactive_page)
    @multichoice = FactoryGirl.create(:multiple_choice)
    @multichoice.create_default_choices
    @multichoice.reload
    @page.add_embeddable(@multichoice)
    @page.reload
  end

  describe "a newly created MutipleChoiceQuestion" do    
    it "belongs to a page" do
      @page.embeddables.should_not be_nil
      @page.embeddables.should include(@multichoice)
    end
    
    it "has three initial default answers" do
      @multichoice.choices.should have(3).answers
    end

    it "has a self-generated storage key" do
      @multichoice.storage_key.should_not be_nil
    end
  end

  describe "adding a new choice" do
    before(:each) do
      @choice = @multichoice.add_choice("my choice")
      @multichoice.reload
    end
    
    it "should have the new choice" do
      @multichoice.choices.should include(@choice)
    end
  
    it "should update its choices when saved" do
      @choice.choice = "fooo"
      @choice.save
      @multichoice.reload
      @multichoice.choices[3].choice.should == "fooo"
    end
      
    describe '#to_hash' do
      it 'returns a hash with copied attributes' do
        expected = { name: @multichoice.name, prompt: @multichoice.prompt, custom: @multichoice.custom, enable_check_answer: @multichoice.enable_check_answer }
        @multichoice.to_hash.should == expected
      end
    end

    describe '#duplicate' do
      it 'returns a new instance with copied attributes' do
        @multichoice.duplicate.should be_a_new(Embeddable::MultipleChoice).with( name: @multichoice.name, prompt: @multichoice.prompt )
      end

      it 'copies choices' do
        c = @multichoice.choices.first
        c.duplicate.should be_a_new(Embeddable::MultipleChoiceChoice).with( choice: c.choice, prompt: c.prompt, is_correct: c.is_correct )
      end

      it 'has copied choices' do
        @multichoice.duplicate.choices.length.should be(@multichoice.choices.length)
      end
    end
  end

end
