class Money
  def initialize()
  end

  def rent(listing, renter, card)
    # get listing owner
    owner = listing.user

    # add card to renter
    balanced.add_card!(renter, card)

    # create a new rental
    rental = Rental.new(
      listing: listing,
      buyer: renter,
      owner: owner
    )

    # debit renter customer
    debit = debit(rental)

    # credit owner customer
    credit = credit(rental) 

    rental.save
    return rental
  end

  def debit(rental)
    debit = balanced.debit(rental)
    subledger.debit(rental, debit.uri)
  end

  def credit(rental)
    credit = balanced.credit(rental)
    subledger.credit(rental, credit.uri)
  end

private
  def balanced
    @balanced ||= RentMyBike::Balanced
  end

  def subledger
    @subledger ||= RentMyBike::Subledger
  end
end
