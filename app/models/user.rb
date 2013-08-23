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

  before_create :setup_balanced_account
  before_create :setup_subledger_accounts

  def customer
    self.balanced
    Balanced::Customer.find(self.customer_uri)
  end

  def add_card(card_uri)
    customer = self.customer
    customer.add_card(card_uri)
  end

  def ar_account
    self.subledger.new_or_create(id: self.ar_acct_id, description: self.name) do |ar|
      self.ar_acct_id = ar.id
    end
  end

  def ap_account
    self.subledger.new_or_create(id: self.ap_acct_id, description: self.name) do |ap|
      self.user.ap_acct_id = ap.id
    end
  end

  def revenue_account
    self.subledger.new_or_create(id: self.revenue_acct_id, description: self.name) do |revenue|
      self.user.ap_acct_id = revenue.id
    end
  end

private
  def setup_balanced_account
    # initialize balanced
    self.balanced

    # create customer
    customer = Balanced::Marketplace.mine.create_customer(
      name: self.name,
      email: self.email
    )

    # save customer uri
    self.customer_uri = customer.uri
  end

  def setup_subledger_accounts
    self.ar_account
    self.ap_account
    self.revenue_account
  end

  def balanced
    @balanced ||= Balanced::Marketplace.my_marketplace
  end

  def subleder
    @subleder ||= Subledger.new
  end

end
