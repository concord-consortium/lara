require 'spec_helper'

describe PortalSender::Protocol do
  let(:endpoint)            { "http://localhost/dataservice/external_activity_data/6" }
  let(:auth_stubs)          { {} }
  let(:protocol)            { PortalSender::Protocol.new       }
  let(:mock_auth_provider)  { double(auth_stubs)               }
  let(:post_results)        { {}                               }
  let(:answer_data)         { double({portal_hash: {one: 1},
                                      updated_at: Time.now,
                                      dirty?: true}) }
  let(:sad_result)   { double({ success?: false, code: 500, message: 'failure'})}
  let(:happy_result) { double({ success?: true, code: 200, message: 'yipee'})}

  before(:each) do
    allow(Run).to receive(:auth_provider).and_return mock_auth_provider
    allow(HTTParty).to receive(:post).and_return post_results
    allow(Concord::AuthPortal).to receive(:auth_token_for_url).and_return "xyzzy"
  end


  describe "add-hoc routing maddness" do

  end

  describe "when the portal supports the latest version of the protocol" do
    let(:post_results) { happy_result }
    it "should use the most rescent protocol version after sending" do
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.first
    end
  end

  describe "when the portal is using an older version of the protocol" do
    let(:post_results) { sad_result }
    it "should not be using the most rescent protocol version after sending" do
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.last
    end
  end

  describe "retrying the first version again after some time passes" do

    let(:post_results) { sad_result }
    it "should not be using the most rescent protocol version after sending" do
      # Using old version
      allow(HTTParty).to receive(:post).and_return sad_result
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.last

      # Checkin again in the future:
      Timecop.travel(3.hours.from_now)
      allow(HTTParty).to receive(:post).and_return happy_result
      protocol.post_answers(answer_data, endpoint)
      expect(protocol.version).to eq PortalSender::Protocol::Versions.first
    end
  end

  describe "#instance and caching protocols for servers" do
    let(:endpoint_a)  { "http://localhost/dataservice/external_activity_data/6"    }
    let(:endpoint_b)  { "http://localhost/dataservice/external_activity_data/7"    }
    let(:endpoint_c)  { "http://localhost:80/dataservice/external_activity_data/8" }
    let(:endpoint_d)  { "http://127.0.0.1/dataservice/external_activity_data/6"    }
    let(:endpoint_e)  { "http://google.com/dataservice/external_activity_data/6"    }

    describe "when multiple endpoints use the same serve" do
      it "should return the same protocol" do
        expect(PortalSender::Protocol.instance(endpoint_a)).to eq PortalSender::Protocol.instance(endpoint_b)
        expect(PortalSender::Protocol.instance(endpoint_b)).to eq PortalSender::Protocol.instance(endpoint_c)
      end
    end

    describe "when endpoints use different servers" do
      it "should use a new protocol for each one" do
        expect(PortalSender::Protocol.instance(endpoint_a)).not_to eq PortalSender::Protocol.instance(endpoint_d)
        expect(PortalSender::Protocol.instance(endpoint_d)).not_to eq PortalSender::Protocol.instance(endpoint_e)
      end
    end
  end




    describe '#response_for_portal' do
      let(:or_question){ FactoryBot.create(:or_embeddable) }
      let(:or_answer)  { FactoryBot.create(:or_answer, { answer_text: "the answer", question: or_question }) }
      let(:image_quest){ FactoryBot.create(:image_question, prompt: "draw your answer") }
      let(:iq_answer)  { FactoryBot.create(:image_question_answer,
                                            { answer_text: "the image question answer",
                                              question: image_quest,
                                              annotated_image_url: "http://foo.com/bar.jpg" }) }
      let(:a1)         { FactoryBot.create(:multiple_choice_choice, choice: "answer_one") }
      let(:a2)         { FactoryBot.create(:multiple_choice_choice, choice: "answer_two") }
      let(:mc_question){ FactoryBot.create(:multiple_choice, choices: [a1, a2]) }
      let(:mc_answer)  { FactoryBot.create(:multiple_choice_answer, answers: [a1], question: mc_question) }

      let(:one_answer)  { or_answer }
      let(:all_answers) { [or_answer, mc_answer,iq_answer] }

      let(:one_expected) do
        [{
             "type" => "open_response",
             "question_id" => or_question.id.to_s,
             "answer" => or_answer.answer_text,
             "is_final" => or_answer.is_final
         }]
      end
      let(:all_expected) do
         [{
              "type" => "open_response",
              "question_id" => or_question.id.to_s,
              "answer" => or_answer.answer_text,
              "is_final" => or_answer.is_final
          },
          {
              "type" => "multiple_choice",
              "question_id" => mc_question.id.to_s,
              "answer_ids" => [ a1.id.to_s],
              "answer_texts" => [ a1.choice],
              "is_final" => mc_answer.is_final
          },
          {
              "type" => "image_question",
              "question_id" => iq_answer.question.id.to_s,
              "answer" => iq_answer.answer_text,
              "is_final" => iq_answer.is_final,
              "image_url" => iq_answer.annotated_image_url
        }]
      end

      describe "version 0 of the sending protocol" do
        it 'matches the expected JSON for a single specified answer' do
          expected_serialized  = one_expected
          expect(JSON.parse(protocol.response_for_portal(one_answer))).to eq(expected_serialized)
        end

        it "matches the expected JSON for multiple specified answers" do
          expected_serialized = all_expected
          expect(JSON.parse(protocol.response_for_portal(all_answers))).to eq(expected_serialized)
        end
      end

      describe "version 1 of the sending protocol" do
        let(:frozen_time)  { Time.now.utc.to_s }
        before(:each) do
          Timecop.freeze(Time.new(2016))
        end

        it 'matches the expected JSON for a single specified answer' do
          expected_serialized  = {
            "answers"    => one_expected,
            "lara_end"   => frozen_time,
            "version"    => "1"
          }
          one_answer_json = protocol.response_for_portal_1_0(one_answer)
          expect(JSON.parse(one_answer_json)).to eq(expected_serialized)
        end

        it "matches the expected JSON for multiple specified answers" do
          expected_serialized = {
              "answers"    => all_expected,
              "lara_end"   => frozen_time,
              "version"    => "1"
          }
          all_answers_json = protocol.response_for_portal_1_0(all_answers)
          expect(JSON.parse(all_answers_json)).to eq(expected_serialized)
        end

        it 'sends lara_start only when it is provided' do
          first_one_answer_json = protocol.response_for_portal_1_0(one_answer)
          expect(JSON.parse(first_one_answer_json)).not_to include("lara_start")

          start_time = Time.now
          second_one_answer_json = protocol.response_for_portal_1_0(one_answer, start_time)
          expect(JSON.parse(second_one_answer_json)).to include(
            "lara_start" => start_time.utc.to_s
          )
        end
      end

    end

end
