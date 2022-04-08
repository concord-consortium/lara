class GlossariesController < ApplicationController
  load_and_authorize_resource

  def index
    if current_user
      if current_user.admin?
        @glossaries = Glossary.all(order: :name)
      else 
        @glossaries = current_user.glossaries
      end
    else 
      @glossaries = []
    end
  end

  def new
    @glossary = Glossary.new()
  end

  def create
    @glossary = Glossary.new(params[:glossary])
    @glossary.user = current_user

    if @glossary.save
      redirect_to edit_glossary_url(@glossary), notice: 'Glossary was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    simple_update(@glossary)
  end

  def destroy
    @glossary.destroy
    redirect_to glossaries_url
  end

end
