class UpdatePublicationStatusNames < ActiveRecord::Migration

  class Sequence < ActiveRecord::Base
  end

  class LightweightActivity < ActiveRecord::Base
  end

  def up
    change_column :lightweight_activities, :publication_status, :string, :default => 'private'
    change_column :sequences, :publication_status, :string, :default => 'private'

    LightweightActivity.update_all({ publication_status: 'hidden' }, { publication_status: 'private' })
    LightweightActivity.update_all({ publication_status: 'private' }, { publication_status: 'draft' })
    Sequence.update_all({ publication_status: 'hidden' }, { publication_status: 'private' })
    Sequence.update_all({ publication_status: 'private' }, { publication_status: 'draft' })
  end

  def down
    change_column :lightweight_activities, :publication_status, :string, :default => 'draft'
    change_column :sequences, :publication_status, :string, :default => 'draft'

    LightweightActivity.update_all({ publication_status: 'draft' }, { publication_status: 'private' })
    LightweightActivity.update_all({ publication_status: 'private' }, { publication_status: 'hidden' })
    Sequence.update_all({ publication_status: 'draft' }, { publication_status: 'private' })
    Sequence.update_all({ publication_status: 'private' }, { publication_status: 'hidden' })
  end
end
