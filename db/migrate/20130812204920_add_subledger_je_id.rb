class AddSubledgerJeId < ActiveRecord::Migration
  def change
    add_column :rentals, :subledger_je_id, :string
  end
end
