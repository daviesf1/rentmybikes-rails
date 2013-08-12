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

    lines = [ ]

    debit = renter.debit(
        :amount => self.price*100,
        :description => self.description,
        :on_behalf_of => owner,
    )

    # Subledger Code 
    subledger = MySubledger.new

    lines << { :account     => user.subledger_ar_account,
               :description => self.description,
               :reference   => url_for( debit ),
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
    lines << { :account     => user.subledger_ap_account,
               :description => self.description,
               :reference   => url_for( credit ),
               :value       => subledger.credit( self.price ) }

    rental = Rental.new(
      :debit_uri  => debit.uri,
      :credit_uri => credit.uri,
      :listing_id => self.id,
      :buyer => user,
      :owner => self.user,
    )

    rental.save

    # Subledger Code 
    journal_entry = subledger.
                       journal_entry.
                            create_and_post(
                              :effective_at => Time.now,
                              :description  => self.description,
                              :reference    => "http://rentmybikes.com/rentals/#{rental.id}",
                              :lines        => lines )

    rental.subledger_je_id = journal_entry.id

    rental.save
  end

  private

  def url_for balanced_line
    "https://dashboard.balancedpayments.com/#" + balanced_line.uri[3..-1]
  end

end
