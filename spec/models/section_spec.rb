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

end
