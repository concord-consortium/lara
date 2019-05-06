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

      describe "with query param without a value" do
        let(:url) { "/foo?bar" }
        # This is documenting broken behavior, however this case should not cause problems
        # in practice
        it "adds a '=' to the url and the whitelisted params" do
          expect(append_white_list_params(url)).to eql("/foo?bar=&mode=teacher-edition")
        end
      end

      it "should return the passed url plus append the current default whitelist params" do
        expect(append_white_list_params(url)).to eql("/foo?bar=1&mode=teacher-edition")
      end

      describe "with a url that already contain a whitelisted param" do
        let(:url) { "/foo?bar=1&mode=teacher-edition" }

        it "should not duplicate query params that match whitelist parameters" do
          expect(append_white_list_params(url)).to eql("/foo?bar=1&mode=teacher-edition")
        end
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

      describe "with query string that includes escaped characters" do
        let(:domain) { "https://example.com" }
        let(:query_param_1) { "server=https%3A%2F%2Fexample.com%2Flatest%3Fmode%3Dsomething%26test" }
        let(:query_param_2) { "scaling=true" }
        let(:url) { "#{domain}?#{query_param_1}&#{query_param_2}" }
        # the code seems to order the parameters alphabetically
        let(:result) { "#{domain}?mode=teacher-edition&#{query_param_2}&#{query_param_1}" }
        it "should return the url plus the whitelisted params" do
          expect(append_white_list_params(url)).to eql(result)
        end
      end
    end
  end
end
