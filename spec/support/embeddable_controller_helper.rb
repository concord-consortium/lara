require 'factory_girl'

shared_examples_for 'an embeddable controller' do
  render_views

  controller_class_lambda = lambda { self.send(:described_class) }
  model_class_lambda      = lambda { controller_class_lambda.call.name[/(.*)Controller/, 1].singularize.constantize }
  model_ivar_name_lambda  = lambda { model_class_lambda.call.name.delete_module.underscore_module }

  def create_new(model_name)
    method_name = "create_new_#{model_name}".to_sym
    if self.respond_to?(method_name)
      return self.send(method_name)
    else
      return FactoryGirl.create(model_name)
    end
  end

  before(:each) do
    @model_class = model_class_lambda.call
    @model_ivar_name = model_ivar_name_lambda.call
    unless instance_variable_defined?("@#{@model_ivar_name}".to_sym)
      @model_ivar = instance_variable_set("@#{@model_ivar_name}", create_new(@model_ivar_name))
    end
  end

end
