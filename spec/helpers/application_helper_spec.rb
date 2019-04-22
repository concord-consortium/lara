require "spec_helper"

describe ApplicationHelper do

  describe "#append_white_list_params" do
    let(:url) { "/foo?bar=1" }

    describe "without params" do
      let(:params) { {} }

      describe "without query string" do

        describe "without protocol" do
          let(:url) { "/foo" }
          it "should return the passed url if there are no current params" do
            expect(append_white_list_params(url)).to eql(url)
          end

          describe "with query string" do
            let(:url) { "/foo?bar=1" }
            it "should return the passed url if there are no current params" do
              expect(append_white_list_params(url)).to eql(url)
            end
          end
        end

        describe "with protocol" do
          let(:url) { "http://example.com/foo" }
          it "should return the passed url if there are no current params" do
            expect(append_white_list_params(url)).to eql(url)
          end

          describe "with query string" do
            let(:url) { "http://example.com/foo?bar=1" }
            it "should return the passed url if there are no current params" do
              expect(append_white_list_params(url)).to eql(url)
            end
          end
        end
      end
    end

    describe "with params" do
      let(:params) { {"mode" => "teacher-edition", "foo" => "bar", "baz" => "boom"} }

      it "should return the passed url plus append the current default whitelist params" do
        expect(append_white_list_params(url)).to eql("/foo?bar=1&mode=teacher-edition")
      end

      it "should return the passed url plus append the current passed whitelist params" do
        expect(append_white_list_params(url, ["baz"])).to eql("/foo?bar=1&baz=boom")
      end

      it "should return the passed url when the whitelist params is empty" do
        expect(append_white_list_params(url, [])).to eql(url)
      end

      it "should return the passed url when the whitelist params does not intersect" do
        expect(append_white_list_params(url, ["bing"])).to eql(url)
      end
    end
  end
end
