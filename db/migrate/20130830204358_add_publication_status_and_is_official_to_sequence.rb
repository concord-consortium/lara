class AddPublicationStatusAndIsOfficialToSequence < ActiveRecord::Migration
  class Sequence < ApplicationRecord
    attr_protected :non_existint_field # make other attrs accessable.
  end

  def up
    add_column :sequences, :publication_status, :string, :default => 'draft'
    add_column :sequences, :is_official, :boolean, :default => false
    # make existing sequences have 'public' as publication status
    Sequence.reset_column_information
    Sequence.all.each { |s| s.update_attributes(publication_status: 'public', is_official: true)}
  end
  def down
    remove_column :sequences, :publication_status
    remove_column :sequences, :is_official
  end

end
