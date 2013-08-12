module MySubledger
  def self.new
    Boocx.new :key_id  => ENV['BOOCX_KEY_ID'],
              :org_id  => ENV['BOOCX_ORG_ID'],
              :book_id => ENV['BOOCX_BOOK_ID']
  end
end
