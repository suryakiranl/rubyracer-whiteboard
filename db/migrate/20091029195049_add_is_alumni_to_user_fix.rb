class AddIsAlumniToUserFix < ActiveRecord::Migration
  def self.up
    add_column :user_verions, :is_alumnus, :boolean
  end

  def self.down
    remove_column :user_verions, :is_alumnus

  end
end
