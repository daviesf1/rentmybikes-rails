class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # devise attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # app specific attributes
  attr_accessible :name, :customer_uri

  has_many :owner_rentals, :class_name => 'Rental', :foreign_key => 'owner_id'
  has_many :buyer_rentals, :class_name => 'Rental', :foreign_key => 'buyer_id'

  has_many :listings

  def balanced_customer
    return Balanced::Customer.find(self.customer_uri) if self.customer_uri

    begin
      customer = self.class.create_balanced_customer(
        :name   => self.name,
        :email  => self.email
        )
    rescue
      'There was error fetching the Balanced customer'
    end

    self.customer_uri = customer.uri
    self.save
    customer
  end

  def add_card(card_uri)
    customer = self.balanced_customer
    customer.add_card(card_uri)
  end

  def ar_account

    self.subledger.accounts.new_or_create(
      id: self.subledger_ar_acct_id,
      description: self.name,
      normal_balance: self.subledger.credit) do |ar|

      self.subledger_ar_acct_id = ar.id
    end
  end

  def ap_account
    self.subledger.accounts.new_or_create(
      id: self.subledger_ap_acct_id,
      description: self.name,
      normal_balance: self.subledger.credit) do |ap|

      self.subledger_ap_acct_id = ap.id
    end
  end

  def revenue_account
    self.subledger.accounts.new_or_create(
      id: self.subledger_revenue_acct_id,
      description: self.name,
      normal_balance: self.subledger.credit) do |revenue|

      self.subledger_revenue_acct_id = revenue.id
    end
  end

  def subledger
    @subledger ||= MySubledger.new
  end

  def self.create_balanced_customer(params = {})
    begin
      Balanced::Marketplace.mine.create_customer(
        :name   => params[:name],
        :email  => params[:email]
        )
    rescue
      'There was an error adding a customer'
    end
  end

end

