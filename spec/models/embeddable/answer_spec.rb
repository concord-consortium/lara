require File.expand_path('../../../spec_helper', __FILE__)

# we are testing features of a module

class TestClass < Struct.new(:prompt)
  include ::Embeddable::Answer
end

describe TestClass do
  let (:prompt_a_no_itals)   { "<i></i> A" }
  let (:prompt_b_no_itals)   { "<i></i> B" }

  let (:prompt_a)            { "<i>Prompt</i> A" }
  let (:prompt_b)            { "<i>Prompt</i> B" }

  let (:answer_a)            { TestClass.new(prompt_a) }
  let (:answer_b)            { TestClass.new(prompt_b) }

  describe '#prompt_no_itals' do
    it "should remove any content in itals from the original prompt" do
      answer_a.prompt_no_itals.should == prompt_a_no_itals
    end

    it "should work for two-consecutive calls on different objects" do
      answer_a.prompt_no_itals.should == prompt_a_no_itals
      answer_b.prompt_no_itals.should == prompt_b_no_itals
    end
  end
end
