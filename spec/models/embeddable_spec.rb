require 'spec_helper'

describe Embeddable do

  describe 'class methods' do
    describe 'get_embeddable_class' do
      it 'returns an embeddable class name' do
        Embeddable.get_types().each do |t|
          embeddable_class = Embeddable.get_embeddable_class(t)
          expect(embeddable_class).to eql(t.to_s.demodulize.underscore)
        end
      end
    end

    describe 'parse_embeddable_id!' do
      it 'handles invalid embeddable_ids' do
        expect { Embeddable.parse_embeddable_id!('') }.to raise_error(ArgumentError, 'Not a valid Embeddable id')
        expect { Embeddable.parse_embeddable_id!('foo') }.to raise_error(ArgumentError, 'Not a valid Embeddable id')
        expect { Embeddable.parse_embeddable_id!('foo_bar') }.to raise_error(ArgumentError, 'Not a valid Embeddable id')
        expect { Embeddable.parse_embeddable_id!('foo_1') }.to raise_error(ArgumentError, 'Not a valid Embeddable class')
        expect { Embeddable.parse_embeddable_id!('foo_100') }.to raise_error(ArgumentError, 'Not a valid Embeddable class')
      end

      it 'parses valid embeddable_ids' do
        Embeddable.get_types().each do |t|
          parsed_class, parsed_id = Embeddable.parse_embeddable_id!("#{Embeddable.get_embeddable_class(t)}_100")
          expect(parsed_class).to eql(t.to_s)
          expect(parsed_id).to eql(100)
        end
      end
    end
  end
end