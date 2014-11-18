class InteractivePage < ActiveRecord::Base
  attr_accessible :lightweight_activity, :name, :position, :text, :layout, :sidebar, :show_introduction, :show_sidebar, :show_interactive, :show_info_assessment, :embeddable_display_mode, :sidebar_title

  belongs_to :lightweight_activity, :class_name => 'LightweightActivity', :touch => true

  acts_as_list :scope => :lightweight_activity

  LAYOUT_OPTIONS = [{ :name => 'Full Width',               :class_val => 'l-full-width' },
                    { :name => '60-40',                    :class_val => 'l-6040' },
                    { :name => '70-30',                    :class_val => 'l-7030' },
                    { :name => '60-40 (interactive left)', :class_val => 'r-4060' },
                    { :name => '70-30 (interactive left)', :class_val => 'r-3070' }]

  EMBEDDABLE_DISPLAY_OPTIONS = ['stacked','carousel']

  INTERACTIVE_TYPES = [{ :name => 'Image',  :class_name => 'ImageInteractive' },
                       { :name => 'Iframe', :class_name => 'MwInteractive' },
                       { :name => 'Video',  :class_name => 'VideoInteractive' }]
  validates :sidebar_title, presence: true
  validates :layout, :inclusion => { :in => LAYOUT_OPTIONS.map { |l| l[:class_val] } }
  validates :embeddable_display_mode, :inclusion => { :in => EMBEDDABLE_DISPLAY_OPTIONS }

  # Reject invalid HTML inputs
  # See https://www.pivotaltracker.com/story/show/60459320
  validates :text, :sidebar, :html => true
  # validates :sidebar, :html => true

  has_many :interactive_items, :order => :position, :dependent => :destroy, :include => [:interactive]
  # InteractiveItem is a join model; if this is deleted, it should go too

  # This is a sort of polymorphic has_many :through.
  def interactives
    self.interactive_items.collect{|ii| ii.interactive}
  end

  has_many :page_items, :order => :position, :dependent => :destroy, :include => [:embeddable]
  # Like InteractiveItems, PageItems are join models, so they should not
  # survive the deletion of associated instances of InteractivePage.

  # This is a sort of polymorphic has_many :through.
  def embeddables
    self.page_items.collect{|qi| qi.embeddable}
  end

  def add_interactive(interactive, position = nil, validate = true)
    self[:show_interactive] = true;
    self.save!(validate: validate)
    InteractiveItem.create!(:interactive_page => self, :interactive => interactive, :position => (position || self.interactive_items.size))
  end

  def remove_interactives
    self[:show_interactive] = false;
    self.save!
    self.interactives.each do |i|
      i.destroy
    end
    self.interactive_items.each do |ii|
      ii.destroy
    end
  end

  def add_embeddable(embeddable, position = nil)
    join = PageItem.create!(:interactive_page => self, :embeddable => embeddable, :position => position)
    unless position
      join.move_to_bottom
    end
  end

  def to_hash
    # Intentionally leaving out:
    # - lightweight_activity association will be added there
    # - user will get the new user
    # - Associations will be done later
    {
      name: name,
      position: position,
      text: text,
      layout: layout,
      sidebar: sidebar,
      sidebar_title: sidebar_title,
      show_introduction: show_introduction,
      show_sidebar: show_sidebar,
      show_interactive: show_interactive,
      show_info_assessment: show_info_assessment
    }
  end

  def set_list_position(index)
    # Overloads the acts_as_list version
    self.position = index
    self.save!(:validate => false) # This is the part we need to override
  end

  def duplicate
    new_page = InteractivePage.new(self.to_hash)
    InteractivePage.transaction do
      new_page.save!(validate: false)
      self.interactives.each do |inter|
        new_page.add_interactive(inter.duplicate, nil, false)
      end
      self.embeddables.each do |embed|
        copy = embed.duplicate
        copy.save!(validate: false)
        new_page.add_embeddable(copy)
      end
    end
    return new_page
  end
  
  def export
    
    #new_page = InteractivePage.new(self.to_hash)
    
    page_json = self.as_json(only: [:name, 
                                    :position, 
                                    :text, 
                                    :layout, 
                                    :sidebar, 
                                    :sidebar_title, 
                                    :show_introduction, 
                                    :show_sidebar, 
                                    :show_interactive,
                                    :show_info_assessment])
                                        
    page_json[:interactive] = []
    page_json[:embeddable] = []
        
    self.interactives.each do |inter|
      page_json[:interactive] << inter.as_json(only:[:caption, 
                                                     :credit, 
                                                     :height, 
                                                     :width, 
                                                     :poster_url])
    end
    self.embeddables.each do |embed|
      page_json[:embeddable] << embed.as_json(only:[:show_as_menu,
                                                    :prompt,
                                                    :prediction_feedback,
                                                    :name,:custom,
                                                    :enable_check_answer,
                                                    :give_prediction_feedback,
                                                    :is_prediction,
                                                    :multi_answer])
    end
  
    return page_json
  end
end
