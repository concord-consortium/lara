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

  let(:first_mc_choice_id) { multichoice.choices.first.id }

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
  end

  describe '#parse_choices' do
    it 'should return an empty array for a blank input' do
      multichoice.parse_choices('').should == []
    end

    it 'should return an array with one MultipleChoiceChoice when passed an integer' do
      choice_key = multichoice.choices.first.id.to_s
      multichoice.parse_choices(choice_key).should == [multichoice.choices.first]
      multichoice.parse_choices(choice_key).first.should be_a_kind_of Embeddable::MultipleChoiceChoice
    end

    it 'should return an array of several MultipleChoiceChoices when passed a list of comma-separated integers' do
      choice_key = multichoice.choices.map{ |c| c.id }.join(',')
      multichoice.parse_choices(choice_key).length.should == multichoice.choices.length
      multichoice.parse_choices(choice_key).first.should be_a_kind_of Embeddable::MultipleChoiceChoice
    end
  end

  describe '#check' do
    describe 'when the MultipleChoice is not multi-answer' do
      it 'should return a MultipleChoiceChoice instance' do
        multichoice.check("#{first_mc_choice_id}").should be_a_kind_of Embeddable::MultipleChoiceChoice
      end
    end

    describe 'when the MultipleChoiceChoice is multi-answer' do
      let (:multichoice) do
        mc = FactoryGirl.create(:multiple_choice, :multi_answer => true)
        mc.create_default_choices
        mc.choices[0].is_correct = true
        mc.choices[0].save
        mc.choices[1].is_correct = true
        mc.choices[1].save
        mc.reload
        mc
      end

      it 'should return a hash with at least one key' do
        multichoice.check("#{first_mc_choice_id}").should be_a_kind_of Hash
        multichoice.check("#{first_mc_choice_id}").length.should be(1)
      end

      it 'should return a prompt for a nil answer' do
        multichoice.check('').should == { prompt: 'Please select an answer before checking.' }
      end

      it 'should return true for all right answers' do
        multichoice.check("#{multichoice.choices[0].id.to_s},#{multichoice.choices[1].id.to_s}").should == { choice: true }
      end

      it 'should return a prompt for some right answers, but not all' do
        multichoice.check(multichoice.choices[1].id.to_s).should == { prompt: "You're on the right track, but you didn't select all the right answers yet." }
      end

      it 'should return a list of wrong answers' do
        w_choice = multichoice.choices.last
        multichoice.check(w_choice.id.to_s).should == { prompt: "'#{w_choice.choice}' is incorrect" }
      end
    end
  end

  describe '#to_hash' do
    it 'returns a hash with copied attributes' do
      expected = { name: multichoice.name, prompt: multichoice.prompt, custom: multichoice.custom, enable_check_answer: multichoice.enable_check_answer, multi_answer: multichoice.multi_answer, show_as_menu: multichoice.show_as_menu }
      multichoice.to_hash.should == expected
    end
  end

  describe '#export' do
    it 'returns json of a video interactive' do
      multichoice_json = multichoice.export.as_json
      multichoice_json['choices'].length.should == multichoice.choices.count
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
