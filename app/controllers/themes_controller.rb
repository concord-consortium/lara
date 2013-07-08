class ThemesController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
    @theme = Theme.new()
  end

  def edit
  end

  def create
    @theme = Theme.new(params[:theme])
    respond_to do |format|
      if @theme.save
        format.html { redirect_to edit_theme_url(@theme), notice: 'Theme was successfully created.' }
        format.json { render json: @theme, status: :created, location: @theme }
      else
        format.html { render action: "new" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @theme.update_attributes(params[:theme])
        format.html { redirect_to edit_theme_url(@theme), notice: 'Theme was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end
end
