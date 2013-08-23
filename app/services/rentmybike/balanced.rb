module RentMyBike do

  class Balanced
    def initialize()
      @marketplace = Balanced::Marketplace.my_marketplace
    end
  
    def debit(rental)
      owner_customer = rental.owner.customer
      renter_customer = rental.renter.customer

      debit = renter_customer.debit(
        amount: rental.price,
        description: rental.listing.description,
        on_behalf_of: owner_customer
      )

      rental.debit_uri = debit.uri
      rental.save

      return debit
    end

    def credit(rental)
      owner_customer = rental.owner.customer

      credit = owner_customer.credit(
        amount: rental.price,
        description: rental.listing.description
      )

      rental.credit_uri = credit.uri
      rental.save

      return credit
    end
  end

end
