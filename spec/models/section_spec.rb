require 'spec_helper'

describe Section do
  let(:params)  { {} }
  let(:section) { Section.create(params) }

  describe "Create section" do
    describe "without any params" do
      it "should be valid" do
        expect(section).to be_valid
      end
    end

    describe "with default params" do
      let(:params) { Section::DEFAULT_PARAMS }
      it "should be valid" do
        expect(section).to be_valid
      end
      it "should have default properties" do
        expect(section.title).to eql(Section::DEFAULT_SECTION_TITLE)
        expect(section.name).to eql(nil)
        expect(section.layout).to eql(Section::LAYOUT_DFEAULT)
        expect(section.show).to eq(true)
        expect(section.can_collapse_small).to eq(false)
      end
    end
  end

  describe "#css_class_for_item_index" do
    let(:params) { {layout: "bogus"} }
    describe "with an unknown layout" do
      it "should return 'unknown' for a class name" do
        expect(section.css_class_for_item_index(0)).to eql("unknown")
      end
    end
    describe "with specific layouts" do
      describe "with 30 70 layout" do
        let(:params) { { layout: Section::LAYOUT_30_70 } }
        it "should return the correct classes" do
          expect(section.css_class_for_item_index(0)).to eql("section-30")
          expect(section.css_class_for_item_index(1)).to eql("section-70")
          expect(section.css_class_for_item_index(2)).to eql("section-30")
        end
      end
      describe "with 60 40 layout" do
        let(:params) { { layout: Section::LAYOUT_60_40 } }
        it "should return the correct classes" do
          expect(section.css_class_for_item_index(0)).to eql("section-60")
          expect(section.css_class_for_item_index(1)).to eql("section-40")
          expect(section.css_class_for_item_index(2)).to eql("section-60")
        end
      end
      describe "with full width layout" do
        let(:params) { { layout: Section::LAYOUT_FULL_WIDTH } }
        it "should return the correct classes" do
          expect(section.css_class_for_item_index(0)).to eql("section-full-width")
          expect(section.css_class_for_item_index(1)).to eql("section-full-width")
          expect(section.css_class_for_item_index(2)).to eql("section-full-width")
        end
      end
    end
  end

  describe "#duplicate" do
    let(:original) { FactoryGirl.create(:section, :on_page, :with_items) }

    let(:copy) { original.duplicate }

    it "should create a copy of itself" do
      expect(copy.title).to eql(original.title)
      expect(copy.name).to eql(original.name)
      expect(copy.layout).to eql(original.layout)
      expect(copy.can_collapse_small).to eql(original.can_collapse_small)
      expect(copy.show).to eql(original.show)

      expect(copy.interactive_page).to be_valid
    end

    describe "its items" do
      it "should copy the items" do
        expect(copy.page_items.length).to eql(3)
      end

      it "should copy all the page_item fields" do
        copy.page_items.each_with_index do |item, index|
          expect(item.column).to eql(original.page_items[index].column)
        end
      end
      it "should copy the item embeddables" do
        original_embeddable_ids = original.embeddables.map(&:id)
        expect(copy.embeddables.length).to eql(original.embeddables.length)
        copy.embeddables.map(&:id).map do |copy_e_id|
          expect(original_embeddable_ids).not_to include(copy_e_id)
        end
      end
    end

  end

end
