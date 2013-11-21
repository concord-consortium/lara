require File.expand_path('../../../spec_helper', __FILE__)

# we are testing features of a module

class TestClass < Struct.new(:prompt)
  include ::Embeddable::Answer
end
def add_italics(string)
  "<i>#{string}</i>"
end

describe TestClass do
  let (:prompt_a_no_itals)   { "Prompt A" }
  let (:prompt_b_no_itals)   { "Prompt B" }

  let (:prompt_a)            { add_italics(prompt_a_no_itals) }
  let (:prompt_b)            { add_italics(prompt_b_no_itals) }

  let (:answer_a)            { TestClass.new(prompt_a) }
  let (:answer_b)            { TestClass.new(prompt_b) }

  describe '#prompt_no_itals' do
    it "should match the original prompt" do
      answer_a.prompt_no_itals.should == prompt_a_no_itals
    end
    it "should work for two-consecutive calls on different objects" do
      answer_a.prompt_no_itals.should == prompt_a_no_itals
      answer_b.prompt_no_itals.should == prompt_b_no_itals
    end
  end

end
