class MoneyService
  def initialize()
  end

  def rent(listing, renter, card)
    # get listing owner
    owner = listing.user

    # add card to renter
    renter.add_card(card)

    # create a new rental
    rental = Rental.new
    rental.listing = listing
    rental.buyer   = renter
    rental.owner   = owner

    # debit renter customer
    debit = debit(rental)

    # credit owner customer
    credit = credit(rental) 

    rental.save!
    return rental
  end

  # encapsulates debit logic
  def debit(rental)
    # make debit operation on balanced
    debit = balanced.debit(rental)

    # account it on subledger
    subledger.debit(rental)
  end

  # encapsulates credit logic
  def credit(rental)
    # make credit operation on balanced
    credit = balanced.credit(rental)

    # account it on subledger
    subledger.credit(rental)
  end

private
  def balanced
    @balanced ||= BalancedService.new
  end

  def subledger
    @subledger ||= SubledgerService.new
  end
end
