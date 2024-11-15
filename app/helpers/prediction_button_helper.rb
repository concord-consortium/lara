module PredictionButtonHelper

  def prediction_button(emb,form)
    return unless emb.respond_to? :is_prediction
    return unless emb.is_prediction
    # render the button
    capture_haml do
      haml_concat form.hidden_field :is_final,  class: 'hidden_is_final'
      haml_tag :div, class: 'still_answering' do
        haml_tag :button,
          type: 'button',
          label: t(:PREDICTION_BUTTON),
          name: "is_final",
          value: t(:PREDICTION_BUTTON),
          class: 'button prediction_button' do
             haml_tag :span do
               haml_concat t(:PREDICTION_BUTTON)
             end
             haml_tag :i, class: "fa fa-lock required"
          end
      end
      haml_tag :div, class: 'is_final' do
        haml_tag :div, :class => 'answer_is_final screen-only', 'data-is-final' => emb.is_final do
          haml_tag :h5 do
            haml_concat t(:ANSWER_IS_FINAL)
            haml_tag :i, class: "fa fa-lock"
          end
          if emb.give_prediction_feedback
            unless emb.prediction_feedback.blank?
              haml_tag :div, class: 'prediction_feedback reveal' do
                haml_concat emb.prediction_feedback
              end
            end
          end
        end
      end
    end
  end
end
