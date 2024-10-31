class ReplaceEmTags < ActiveRecord::Migration
  class Project < ApplicationRecord
  end

  def up
    ReplaceEmTags.replace_em_tags("<em>","<em class=\"credit\">")
  end

  def down
    ReplaceEmTags.replace_em_tags("<em class=\"credit\">","<em>")
  end

private

  def self.replace_em_tags(current_tag,replacement_tag)
    LightweightActivity.find_each do |activity|
      activity.description = activity.description.gsub(current_tag,replacement_tag) unless activity.description.blank?
      activity.related = activity.related.gsub(current_tag,replacement_tag) unless activity.related.blank?
      activity.save
    end

    Sequence.find_each do |seq|
      seq.description = seq.description.gsub(current_tag,replacement_tag) unless seq.description.blank?
      seq.abstract = seq.abstract.gsub(current_tag,replacement_tag) unless seq.abstract.blank?
      seq.save
    end

    ReplaceEmTags::Project.find_each do |p|
      p.footer = p.footer.gsub(current_tag,replacement_tag) unless p.footer.blank?
      p.about = p.about.gsub(current_tag,replacement_tag) unless p.about.blank?
      p.help = p.help.gsub(current_tag,replacement_tag) unless p.help.blank?
      p.save
    end

    InteractivePage.find_each do |page|
      page.sidebar = page.sidebar.gsub(current_tag,replacement_tag) unless page.sidebar.blank?
      page.text = page.text.gsub(current_tag,replacement_tag) unless page.text.blank?
      page.save
    end

    Embeddable::ImageQuestion.find_each do |image|
      image.drawing_prompt = image.drawing_prompt.gsub(current_tag,replacement_tag) unless image.drawing_prompt.blank?
      image.prompt = image.prompt.gsub(current_tag,replacement_tag) unless image.prompt.blank?
      image.prediction_feedback = image.prediction_feedback.gsub(current_tag,replacement_tag) unless image.prediction_feedback.blank? 
      image.save
    end

    Embeddable::MultipleChoice.find_each do |mc|
      mc.prompt = mc.prompt.gsub(current_tag,replacement_tag) unless mc.prompt.blank?
      mc.prediction_feedback = mc.prediction_feedback.gsub(current_tag,replacement_tag) unless mc.prediction_feedback.blank?
      mc.save
    end

    Embeddable::OpenResponse.find_each do |open_resp|
      open_resp.prompt = open_resp.prompt.gsub(current_tag,replacement_tag) unless open_resp.prompt.blank?
      open_resp.prediction_feedback = open_resp.prediction_feedback.gsub(current_tag,replacement_tag) unless open_resp.prediction_feedback.blank?
      open_resp.save
    end

    Embeddable::Xhtml.find_each do |xhtml|
      xhtml.content = xhtml.content.gsub(current_tag,replacement_tag) unless xhtml.content.blank?
      xhtml.save
    end

    Embeddable::Labbook.find_each do |lab|
      lab.prompt = lab.prompt.gsub(current_tag,replacement_tag) unless lab.prompt.blank?
      lab.save
    end
  end
end
