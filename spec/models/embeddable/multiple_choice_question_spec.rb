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
    it "should belong to a page" do
      @page.embeddables.should_not be_nil
      @page.embeddables.should include(@multichoice)
    end
    
    it "should have three initial default answers" do
      @multichoice.choices.should have(3).answers
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
      
  end

end
