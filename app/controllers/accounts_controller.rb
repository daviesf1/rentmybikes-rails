class AccountsController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

  def my_earnings
    now = Time.now
    @account = current_user.ap_account

    # get ap lines
    @lines = @account.lines(
      action: :before,
      effective_at: now,
      limit: 10
    ).reverse

    # TODO use new line balance attribute instead of computing

    # get ap balance
    @balance = @account.balance(at: now)

    render :history
  end

  def my_rentals
    now = Time.now
    @account = current_user.ar_account

    # get ap lines
    @lines = @account.lines(
      action: :before,
      effective_at: now,
      limit: 10
    ).reverse

    # TODO use new line balance attribute instead of computing

    # get ap balance
    @balance = @account.balance(at: now)

    render :history
  end
end
