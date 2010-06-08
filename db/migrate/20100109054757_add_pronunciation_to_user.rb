class AddPronunciationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :pronunciation, :string
    add_column :user_verions, :pronunciation, :string
  end

  def self.down
    remove_column :user_verions, :pronunciation
    remove_column :users, :pronunciation
  end
end
