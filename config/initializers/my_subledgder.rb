module MySubledger
  def self.new
    Subledger.new :key_id  => ENV['SUBLEDGER_KEY_ID'],
                  :secret  => ENV['SUBLEDGER_SECRET'],
                  :org_id  => ENV['SUBLEDGER_ORG_ID'],
                  :book_id => ENV['SUBLEDGER_BOOK_ID']
  end

  def self.escrow_account
    ENV['SUBLEDGER_ESCROW_ID']
  end
end
