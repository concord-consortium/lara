module LogoHelper

  # TODO: This is weird, in this helper we assume @projec & @theme.

  def logo_tag(png="cc-logo.png",title="The Concord Consortium", url="http://concord.org/")
    id    = png.gsub("-logo","")
    img   = image_tag(png, :alt => title, :id => id)
    link_to(img, url, :title => title)
  end

  def project_logo_tag
    project = @project
    if project and !project.logo.blank?
      return logo_tag(project.logo, project.title, project.url)
    end
    return mw_logo_tag
  end

  def sequence_logo_tag
    sequence = @sequence
    return nil unless sequence
    logo = sequence.logo
    if logo.blank?
      logo = "home_blue.png"
    end

    if @sequence_run
      url = sequence_path(:id => sequence.id, :show_index => true, :sequence_run => @sequence_run.id)
    else
      url = sequence_path(:id => sequence.id, :show_index => true)
    end
    buffer = logo_tag(logo, sequence.display_title, url)
    title  = @sequence.display_title.blank? ? @sequence.title : @sequence.display_title
    unless title.blank?
      link = content_tag(:a, title, :class => "sequence_title", :href=> url)
      buffer << content_tag(:h2, link)
    end
    return content_tag(:div, buffer, :class => "sequence_logo_block")
  end

  def concord_logo_tag
    logo_tag
  end

  def mw_logo_tag
    logo_tag("mw-logo.png","Molecular Workbench", "http://mw.concord.org/nextgen")
  end

  def left_logo_tag
    default = mw_logo_tag
    sequence = sequence_logo_tag
    if sequence
      return sequence
    end
    return project_logo_tag
  end

  def right_logo_tag
    if sequence_logo_tag
      return project_logo_tag
    end
    return concord_logo_tag
  end

end
