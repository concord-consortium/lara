class ReplaceEmTags < ActiveRecord::Migration
  def up
  	em_tag = "<em>"
  	em_tag_credit = "<em class='credit'>"

  	LightweightActivity.find_each do |activity|
      activity.description = activity.description.gsub(em_tag,em_tag_credit) unless activity.description.blank?
      activity.related = activity.related.gsub(em_tag,em_tag_credit) unless activity.related.blank?
      activity.save
    end

    Sequence.find_each do |seq|
      seq.description = seq.description.gsub(em_tag,em_tag_credit) unless seq.description.blank?
      seq.abstract = seq.abstract.gsub(em_tag,em_tag_credit) unless seq.abstract.blank?
      seq.save
    end

    Project.find_each do |p|
      p.footer = p.footer.gsub(em_tag,em_tag_credit) unless p.footer.blank?
      p.about = p.about.gsub(em_tag,em_tag_credit) unless p.about.blank?
      p.help = p.help.gsub(em_tag,em_tag_credit) unless p.help.blank?
      p.save
    end

    InteractivePage.find_each do |page|
      page.sidebar = page.sidebar.gsub(em_tag,em_tag_credit) unless page.sidebar.blank?
      page.text = page.text.gsub(em_tag,em_tag_credit) unless page.text.blank?
      page.save
    end

    Embeddable::ImageQuestion.find_each do |image|
      image.drawing_prompt = image.drawing_prompt.gsub(em_tag,em_tag_credit) unless image.drawing_prompt.blank?
      image.prompt = image.prompt.gsub(em_tag,em_tag_credit) unless image.prompt.blank?
      image.prediction_feedback = image.prediction_feedback.gsub(em_tag,em_tag_credit) unless image.prediction_feedback.blank? 
      image.save
    end

    Embeddable::MultipleChoice.find_each do |mc|
      mc.prompt = mc.prompt.gsub(em_tag,em_tag_credit) unless mc.prompt.blank?
      mc.prediction_feedback = mc.prediction_feedback.gsub(em_tag,em_tag_credit) unless mc.prediction_feedback.blank?
      mc.save
    end

    Embeddable::OpenResponse.find_each do |open_resp|
      open_resp.prompt = open_resp.prompt.gsub(em_tag,em_tag_credit) unless open_resp.prompt.blank?
      open_resp.prediction_feedback = open_resp.prediction_feedback.gsub(em_tag,em_tag_credit) unless open_resp.prediction_feedback.blank?
      open_resp.save
    end

    Embeddable::Xhtml.find_each do |xhtml|
      xhtml.content = xhtml.content.gsub(em_tag,em_tag_credit) unless xhtml.content.blank?
      xhtml.save
    end

    Embeddable::Labbook.find_each do |lab|
      lab.prompt = lab.prompt.gsub(em_tag,em_tag_credit) unless lab.prompt.blank?
      lab.save
    end

    CRater::ScoreMapping.find_each do |scoremap|
      scoremap.mapping = scoremap.mapping.gsub(em_tag,em_tag_credit) unless scoremap.mapping.blank?
      scoremap.save
    end
  end

  def down
  end
end
