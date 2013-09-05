class AccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    now = Time.now
    ap_account = current_user.ap_account
    ar_account = current_user.ar_account

    # get ap lines
    ap_lines = ap_account.lines(
      action: :before,
      effective_at: now,
      limit: 10
    )

    # get ar lines
    ar_lines = ar_account.lines(
      action: :before,
      effective_at: now,
      limit: 10
    )

    # get ap and ar balance
    ap_balance = ap_account.balance(at: now)
    ar_balance = ar_account.balance(at: now)

    # merge ap and ar lines
    @lines = ap_lines + ar_lines
    
    # sort lines by effective_at
    @lines = @lines.sort { |a, b| a.effective_at <=> b.effective_at }

    # calculate balance
    @final_balance = ap_balance + ar_balance
  end
end
