RSpec::Matchers.define :be_ordered_by do |attribute|
  match do |actual|
    result = true
    reverse_indicator = "_desc"
    attribute = attribute.to_s
    if attribute =~ /#{reverse_indicator}/
      symbol = attribute.gsub(/#{reverse_indicator}/,'').to_sym
      sorted = actual.sort{ |a,b| b.send(symbol) <=> a.send(symbol)}
    else
      sorted = actual.sort{ |a,b| a.updated_at <=> b.updated_at}
    end
    sorted.each_with_index do |a,i|
      result = false unless actual[i] == a
    end
    result # return true or false for this matcher.
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would be sorted by #{attribute}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be sorted by #{attribute}"
  end

  description do
    "be a sorted by #{attribute}"
  end
end

def make_collection_with_rand_modication_time(factory,count=10,opts={})
  count.times do
    Timecop.travel(rand(Date.parse('2011-01-01')..Date.parse('2012-12-01')))
    FactoryGirl.create(factory.to_sym, opts)
  end
  Timecop.return
end

# force the eval of a let expression for readability
def make(let_expression); end