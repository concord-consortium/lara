require 'spec_helper'

describe Concord::AuthPortal do
  describe "AuthPortal#add" do
    let(:name)       { "name"}
    let(:url)        { "http://foo.bar:3000/"}
    let(:client_id)  { "foo" }
    let(:secret)     { "secret" }
    let(:auth_token) { 'Bearer %s' % secret }
    let(:auth)       { Concord::AuthPortal.add(name,url,client_id,secret) }

    it "it should return an authentication strategy" do
      expect(auth).to be_a_kind_of OmniAuth::Strategies::OAuth2.class
    end

    it "the stratgy name should match the specified name" do
      expect(auth.strategy_name).to match(name)
    end

    it "the secret should be the specified secret" do
      expect(auth.secret).to eq(secret)
    end

    it "the client_id should match the specified client id" do
      expect(auth.id).to eq(client_id)
    end

    it "should have the specified url" do
      expect(auth.url).to eq(url)
    end

    it "should be capabable of generating a controller action" do
      expect(auth.controller_action).to match("def #{auth.strategy_name}")
    end

    describe "finding the strategy that we made" do
      describe "finding by url" do
        describe "when we have a match" do
          it "should return the auth strategy that we made" do
            expect(Concord::AuthPortal.portal_for_url(url)).to eq(auth)
          end
        end
        describe "when we dont have a match" do
          it "it should return nil" do
            expect(Concord::AuthPortal.portal_for_url("bsdfsdfs")).to be_nil
          end
        end
      end
      describe "finding the strategy name by url" do
        describe "when we have a match" do
          it "should return the strategy name" do
            expect(Concord::AuthPortal.strategy_name_for_url(url)).to eq("cc_portal_#{name}")
          end
        end
        describe "when there is no match" do
          it "should raise an error" do
            expect { Concord::AuthPortal.strategy_name_for_url('csdfs')}.to raise_error
          end
        end
      end
      describe "finding the auth token by the url" do
        it "should find the right auth token" do
          expect(Concord::AuthPortal.auth_token_for_url(url)).to eq(auth_token)
        end
      end

      describe "When there many servers on the same host with different ports" do
        it "should use the port number to find the correct auth client" do
          port3333 = Concord::AuthPortal.add("port3333","http://foo.bar:3333/","port3333","3333token")
          expect(Concord::AuthPortal.portal_for_url(url)).to eq(auth) # the original one on port 3000
          expect(Concord::AuthPortal.portal_for_url("http://foo.bar:3333/")).to eq(port3333)
        end
        it "even https and http should be considered different portals" do
          http  = Concord::AuthPortal.add("http","http://foo.bar/","http","httpToken")
          https = Concord::AuthPortal.add("https","https://foo.bar/","https","httpToken")
          expect(Concord::AuthPortal.portal_for_url("https://foo.bar/")).to eq(https)
          expect(Concord::AuthPortal.portal_for_url("http://foo.bar/")).to eq(http)
        end
      end
    end
  end
end
