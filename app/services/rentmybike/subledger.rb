module RentMyBike do

  class Subledger
    def initialize()
      @subledger = MySubledger.new
    end

    def debit(rental)
      listing    = rental.listing
      renter     = rental.buyer
      owner      = rental.owner
      commission = rental.comission
      escrow     = nil # XXX what is this used for?

      @subledger.journal_entry.create_and_post(
        effective_at: Time.now,
        description:  listing.description,
        reference:    listing_url(listing),
        lines:        [
          {
            account: renter.ar_account,
            value: @subledger.debit(rental.price)
          }, {
            account: renter.revenue_account,
            value: @subledger.credit(rental.commission) 
          }, {
            account: owner.ap_account, 
            value: @subledger.credit(rental.net_price)
          }
        ]
      )

      @subledger.journal_entry.create_and_post(
        effective_at: Time.now,
        description:  listing.description,
        reference:    listing_url(listing),
        lines:        [
          {
            account: escrow,
            reference: rental.debit_uri,
            value: @subledger.debit(rental.price)
          },
          {
            account: renter.ar_account,
            reference: rental.debit_uri,
            value: @subledger.credit(rental.price)
          }
        ]
      )
    end

    def credit(rental, reference_uri)
      listing   = rental.listing
      owner     = rental.owner
      escrow    = nil

      @subledger.journal_entry.create_and_post(
        effective_at: Time.now,
        description:  listing.description,
        reference:    listing_url(listing),
        lines:        [
          {
            account: owner.ap_account,
            reference: reference_uri,
            value: @subledger.debit(rental.net_price)
          }, {
            account: escrow,
            reference: reference_uri,
            value: @subledger.credit(rental.net_price)
          }
        ]
      )
    end
  end

end
