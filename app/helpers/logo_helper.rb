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
    logo = sequence.logo || "home_blue.png"
    url = url_for(sequence)
    logo_tag(logo, sequence.title, url)
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
