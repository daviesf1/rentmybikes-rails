# Subledger code ADDED

class Listing < ActiveRecord::Base
  belongs_to :user
  has_many :rentals

  attr_accessible :name, :user_id, :location, :title, :description, :bicycle_type, :price, :owner_uri

  def rent(params = {})

    renter = params[:renter]
    user = params[:user] || User.find_by(:customer_uri => renter.uri)

    # TODO: if a renter already has a valid card, then, use that to charge
    # otherwise, the card_uri should be used as the source
    renter.add_card(params[:card_uri])

    owner = self.user.balanced_customer
  
    # App renter -- Subledger Code 
    # app_renter = user
    
    # App owner -- Subledger Code
    #app_owner = User.find_by(:customer_uri => owner.uri)
    # Does this change the owner_uri on the Listing? If Yes, then it is causing pay-out to fail, 
    # because it's not using the owner with a bank account seeded in seeds.rb
    
    # debit buyer amount of listing
  
    # Subledger Code
    lines = []

    debit = renter.debit(
        :amount => self.price*100,
        :description => self.description,
        :on_behalf_of => owner,
    )
    
    # Subledger Code 
    subledger = ::MySubledger.new
    
        lines << { :account     => user.subledger_ar_account,
                   :description => self.description,
                   :reference   => debit.uri,
                   :value       => subledger.debit( self.price ) }
    
    # credit owner of bicycle amount of listing
    # since this is an example, we're showing how to issue a credit
    # immediately.
    #
    # obviously, you should take advantage of escrow

    credit = owner.credit(
      :amount => self.price,
      :description => self.description
    )

    # Subledger Code 
    #   lines << { :account     => app_owner.subledger_ap_account,
    #              :description => self.description,
    #              :reference   => credit.uri,
    #              :value       => subledger.credit( self.price ) }
  
    rental = Rental.new(
      :debit_uri  => debit.uri,
      :credit_uri => credit.uri,
      :listing_id => self.id,
      :buyer => user,
      :owner => self.user,
    )
    rental.save
reference = "http://rentmybikes.com/rentals/#{rental.id}"
    
  # Subledger Code 
  #  journal_entry = subledger.
       #                journal_entry.
       #                     create_and_post(
       #                       :effective_at => Time.now,
       #                       :description  => self.description,
       #                       :reference    => reference,
       #                       :lines        => lines )
       # 
       # rental.subledger_je_id = journal_entry.id
   
  end

end
