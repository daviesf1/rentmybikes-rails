# Subledger code ADDED

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  :name, :customer_uri

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

#Do we want to add in the find_or_create code here?
def subledger_ar_account
    if self.subledger_ar_acct_id.nil?
      subledger_ar_account = create_subledger_account :ar

      self.subledger_ar_acct_id = subledger_ar_account.id
      self.save
      subledger_ar_account
    else
      subledger.account :id => self.subledger_ar_acct_id
    end
  end

  def subledger_ap_account
    if self.subledger_ap_acct_id.nil?
      subledger_ap_account = create_subledger_account :ap

      self.subledger_ap_acct_id = subledger_ap_account.id
      self.save

      subledger_ap_account
    else
      subledger.account :id => self.subledger_ap_acct_id
    end
  end

  private

  def subledger
    MySubledger.new
  end

  def create_subledger_account type
    case type
      when :ar
        subledger.account.create :description    => "AR: #{self.name}",
                                 :reference      => "https://api.balancedpayments.com#{self.customer_uri}", # ?
                                 :normal_balance => subledger.debit
      when :ap
        subledger.account.create :description    => "AP: #{self.name}",
                                 :reference      => "https://api.balancedpayments.com#{self.customer_uri}", # ?
                                 :normal_balance => subledger.credit
    end
  end
end
