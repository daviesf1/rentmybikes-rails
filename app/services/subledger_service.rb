class SubledgerService

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TextHelper

  def initialize()
    @subledger = MySubledger.new
  end

  def escrow_account
    @subledger.accounts.new_or_create(id: MySubledger.escrow_account)
  end

  def listing_full_url(listing) 
    listing_url(listing, host: "http://balancedpayments.subledger.com/")
  end

  def balanced_url(uri)
    "https://api.balancedpayments.com#{uri}"
  end

  def debit(rental)
    listing    = rental.listing
    renter     = rental.buyer
    owner      = rental.owner
    escrow     = self.escrow_account

    price = BigDecimal.new(rental.price / 100, 2)
    commission = BigDecimal.new((rental.price / 100) * rental.commission_rate, 2)
    net_price = price - commission

    description =  truncate(listing.description, length: 20)

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: renter.ar_account,
          value: @subledger.debit(price),
          description: "Thanks for Renting! - #{description}"
        }, {
          account: renter.revenue_account,
          value: @subledger.credit(commission)
        }, {
          account: owner.ap_account, 
          value: @subledger.credit(net_price),
          description: "Your Bike is Making Money! - #{description}"
        }
      ]
    )

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: escrow,
          reference: self.balanced_url(rental.debit_uri),
          value: @subledger.debit(price)
        },
        {
          account: renter.ar_account,
          reference: self.balanced_url(rental.debit_uri),
          value: @subledger.credit(price),
          description: "Payment Received Thanks! - #{description}"
        }
      ]
    )
  end

  def credit(rental)
    listing   = rental.listing
    owner     = rental.owner
    escrow    = self.escrow_account

    price = BigDecimal.new(rental.price / 100, 2)
    commission = BigDecimal.new((rental.price / 100) * rental.commission_rate, 2)
    net_price = price - commission

    description =  truncate(listing.description, length: 20)

    @subledger.journal_entry.create_and_post(
      effective_at: Time.now,
      description:  listing.description,
      reference:    self.listing_full_url(listing),
      lines:        [
        {
          account: owner.ap_account,
          reference: self.balanced_url(rental.credit_uri),
          value: @subledger.debit(net_price),
          description: "Payment Sent, Enjoy! - #{description}"
        }, {
          account: escrow,
          reference: self.balanced_url(rental.credit_uri),
          value: @subledger.credit(net_price)
        }
      ]
    )
  end
end
