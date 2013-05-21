require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoice do
  let (:multichoice) do
    mc = FactoryGirl.create(:multiple_choice)
    mc.create_default_choices
    mc.reload
    mc
  end

  let (:page) do
    p = FactoryGirl.create(:interactive_page)
    p.add_embeddable(multichoice)
    p.reload
    p
  end

  describe "a newly created MutipleChoiceQuestion" do    
    it "belongs to a page" do
      page.embeddables.should include(multichoice)
    end
    
    it "has three initial default answers" do
      multichoice.choices.should have(3).answers
    end

    # it "has a self-generated storage key" do
    #   multichoice.storage_key.should_not be_nil
    # end
  end

  describe "adding a new choice" do
    let (:choice) { multichoice.add_choice("my choice") }
    
    it "should have the new choice" do
      multichoice.choices.should include(choice)
    end
  
    it "should update its choices when saved" do
      choice.choice = "fooo"
      choice.save
      multichoice.reload
      multichoice.choices[3].choice.should == "fooo"
    end
      
    describe '#to_hash' do
      it 'returns a hash with copied attributes' do
        expected = { name: multichoice.name, prompt: multichoice.prompt, custom: multichoice.custom, enable_check_answer: multichoice.enable_check_answer }
        multichoice.to_hash.should == expected
      end
    end

    describe '#duplicate' do
      it 'returns a new instance with copied attributes' do
        multichoice.duplicate.should be_a_new(Embeddable::MultipleChoice).with( name: multichoice.name, prompt: multichoice.prompt )
      end

      it 'copies choices' do
        c = multichoice.choices.first
        c.duplicate.should be_a_new(Embeddable::MultipleChoiceChoice).with( choice: c.choice, prompt: c.prompt, is_correct: c.is_correct )
      end

      it 'has copied choices' do
        multichoice.duplicate.choices.length.should be(multichoice.choices.length)
      end
    end
  end

end
