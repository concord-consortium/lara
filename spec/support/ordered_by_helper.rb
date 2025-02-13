RSpec::Matchers.define :be_ordered_by do |attribute|
  match do |actual|
    result = true
    reverse_indicator = "_desc"
    attribute = attribute.to_s
    @failers = []

    symbol     = attribute.to_sym
    comparison = Proc.new { |a,b| a.send(symbol) >= b.send(symbol) }

    if attribute =~ /#{reverse_indicator}/
      symbol     = attribute.gsub(/#{reverse_indicator}/,'').to_sym
      comparison = Proc.new { |a,b| a.send(symbol) <= b.send(symbol) }
    end

    actual.each_with_index do |item,i|
      next unless i > 0
      previous = actual[i-1]
      unless comparison.call(item,previous)
        @failers << "#{i} #{actual[i]} is not in order"
        result = false
      end
    end
     result
  end

  failure_message do |actual|
    "expected that #{actual} would be sorted by #{attribute} " + @failers.join(": ")
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be sorted by #{attribute} " + @failers.join(": ")
  end

  description do
    "be a sorted by #{attribute}"
  end
end

def make_collection_with_rand_modication_time(factory,count=10,opts={})
  count.times do
    Timecop.travel(rand(Date.parse('2011-01-01')..Date.parse('2012-12-01')))
    FactoryBot.create(factory.to_sym, opts)
  end
  Timecop.return
end

# force the eval of a let expression for readability
def make(let_expression); end