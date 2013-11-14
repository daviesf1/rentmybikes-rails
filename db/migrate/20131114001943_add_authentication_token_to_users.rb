class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    add_index :users, :authentication_token, unique: true

    User.reset_column_information
    reversible do |dir|
      dir.up do
        User.all.each do |user|
          user.touch
          user.save!
        end
      end
    end
  end

end
