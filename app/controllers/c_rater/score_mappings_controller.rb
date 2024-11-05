class CRater::ScoreMappingsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:index, :create]

  def index
    @filter = CollectionFilter.new(current_user, CRater::ScoreMapping, params[:filter] || {})
    @score_mappings = @filter.collection.includes(:user)
  end

  def new
    respond_to do |format|
      format.js { render json: { html: render_to_string('new'), css_class: "feedback-set" }, content_type: 'text/json' }
      format.html
    end
  end

  def create
    score_mapping = {mapping: params[:c_rater_score_mapping].slice(:score0, :score1, :score2, :score3, :score4, :score5, :score6)}
    @score_mapping = CRater::ScoreMapping.create(score_mapping)
    @score_mapping.description = params[:c_rater_score_mapping][:description]
    @score_mapping.user = current_user
    @score_mapping.changed_by = current_user
    @score_mapping.save
    redirect_back(fallback_location: c_rater_score_mappings_path)
  end

  def edit
    respond_to do |format|
      format.js { render json: { html: render_to_string('edit'), css_class: "feedback-set"}, content_type: 'text/json' }
      format.html
    end
  end

  def update_params
    params.require(:c_rater_score_mapping).permit(:mapping, :description)
  end

  def update
    score_mapping = { mapping: update_params.slice(:score0,:score1,:score2,:score3,:score4,:score5,:score6)}
    @score_mapping.description = update_params[:description]
    @score_mapping.update_attributes(score_mapping)
    @score_mapping.changed_by = current_user
    @score_mapping.save!
    redirect_back(fallback_location: c_rater_score_mappings_path)
  end

  def destroy
    @score_mapping.destroy
    redirect_back(fallback_location: c_rater_score_mappings_path)
  end
end
