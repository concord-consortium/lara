class Project < ApplicationRecord
  DefaultName = 'Default Project'
  DefaultKey = 'default-project'

  validates :project_key, uniqueness: true
  has_many :sequences
  has_many :lightweight_activities
  has_many :project_admins
  has_many :admins, through: :project_admins, source: :user

  default_scope {order('title')}

  protected
  def self.create_default
    self.create(title: DefaultName, logo_lara: '', url: 'https://concord.org/', project_key: DefaultKey)
  end

  public
  def self.default
    self.find_by_title(DefaultName) || self.create_default
  end

  # Derive an OpenGraph-custom logo path from the provided path, or return the provided path if the OG logo doesn't exist
  def og_logo
    if logo
      logo_parts = logo.split('.')
      if logo_parts.length > 1
        # Insert '-og' before the extension but after the filename stem
        stem = "#{logo_parts.first(logo_parts.length - 1).join('.')}-og"
      else
        # No extension: just append '-og' on the end
        stem = "#{logo}-og"
      end
      # Check for stem as .jpg, .jpeg, .png and .gif, then give up
      ogl = nil
      %w(jpg jpeg png gif).each do |ext|
        proposed_filename = "#{stem}.#{ext}"
        if image_file_exists?(proposed_filename)
          ogl = proposed_filename
          break
        end
      end
      unless ogl
        # Can't find the og_logo - just go with the project logo
        ogl = logo
      end
      return ogl
    else
      return nil
    end
  end

  # Check if the derived OpenGraph logo file exists
  def image_file_exists?(filename)
    return File.exists?(Rails.root.join('public', 'assets', filename)) ||
           File.exists?(Rails.root.join('app', 'assets', 'images', filename))
  end

  def export
    project_json = self.as_json(only: [:about,
                                       :footer,
                                       :logo_ap,
                                       :logo_lara,
                                       :project_key,
                                       :title,
                                       :url,
                                       :copyright,
                                       :copyright_image_url,
                                       :collaborators,
                                       :funders_image_url,
                                       :collaborators_image_url,
                                       :contact_email])
    return project_json
  end

  def self.find_or_create(project_data)
    existing_project = Project.where(project_key: project_data[:project_key]).first
    if existing_project.blank?
      new_project = Project.new(about: project_data[:about],
                                footer: project_data[:footer],
                                logo_ap: project_data[:logo_ap],
                                logo_lara: project_data[:logo_lara],
                                project_key: project_data[:project_key],
                                title: project_data[:title],
                                url: project_data[:url],
                                copyright: project_data[:copyright],
                                copyright_image_url: project_data[:copyright_image_url],
                                collaborators: project_data[:collaborators],
                                funders_image_url: project_data[:funders_image_url],
                                collaborators_image_url: project_data[:collaborators_image_url],
                                contact_email: project_data[:contact_email])
      new_project.save
      return new_project
    else
      return existing_project
    end
  end

  def self.visible_to_user(user)
    if user
      if user.is_admin
        self.all
      else
        user.admined_projects
      end
    else
      self.none
    end
  end

  def self.id_and_title(project)
    if project
      {id: project.id, title: project.title}
    else
      nil
    end
  end
end
