class CreateAuthentications < ActiveRecord::Migration
  class User < ApplicationRecord
  end
  class Authentication < ApplicationRecord
  end

  def up
    create_table :authentications do |t|
      t.integer :user_id, :index
      t.string :provider
      t.string :uid
      t.string :token
      t.timestamps
    end
    add_index :authentications, [:user_id, :provider], name: 'index_authentications_on_user_id_and_provider', unique: true
    add_index :authentications, [:uid, :provider], name: 'index_authentications_on_uid_and_provider', unique: true

    Authentication.reset_column_information
    User.reset_column_information
    User.find_each do |user|
      next if user.uid.blank?
      Authentication.create(
        user_id: user.id,
        provider: user.provider,
        uid: user.uid,
        token: user.authentication_token)
    end
    change_table :users do |t|
      t.remove :uid, :provider, :authentication_token
    end
  end
  def down
    change_table :users do |t|
      t.string :uid
      t.string :provider
      t.string :authentication_token
    end
    Authentication.reset_column_information
    User.reset_column_information
    Authentication.find_each do |auth|
      user = User.find(auth.user_id)
      user.update(
        provider: auth.provider,
        uid: auth.uid,
        authentication_token: auth.token)
    end
    drop_table :authentications
  end
end
