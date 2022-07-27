class AddApFooterFieldsToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :copyright, :text
    add_column :projects, :copyright_image_url, :string
    add_column :projects, :collaborators, :text
    add_column :projects, :funders_image_url, :string
    add_column :projects, :collaborators_image_url, :string
    add_column :projects, :contact_email, :string
    remove_column :projects, :help
  end

  def down
    remove_column :projects, :copyright
    remove_column :projects, :copyright_image_url
    remove_column :projects, :collaborators
    remove_column :projects, :funders_image_url
    remove_column :projects, :collaborators_image_url
    remove_column :projects, :contact_email
    add_column :projects, :help, :text
  end
end
