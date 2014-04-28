module PredictionButtonHelper

  def prediction_button(emb,form)
    return unless emb.respond_to? :is_prediction
    return unless emb.is_prediction
    # render the button
    capture_haml do
      haml_concat form.hidden_field :is_final,  :class => 'hidden_is_final'
      haml_tag :button,
        :type => 'button',
        :label => t(:PREDICTION_BUTTON),
        :name  => "is_final",
        :value => t(:PREDICTION_BUTTON),
        'data-is-final' => emb.is_final,
        :class => 'button prediction_button' do
           haml_tag :span do
             haml_concat t(:PREDICTION_BUTTON)
           end
           haml_tag :i, :class => "fa fa-unlock"
           haml_tag :i, :class => "fa fa-lock"
        end
      haml_tag :div, :class => 'answer_is_final', 'data-is-final' => emb.is_final do
        haml_concat t(:ANSWER_IS_FINAL)
      end
    end
  end
end
