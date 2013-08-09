module SubledgerHelper
  def format_amount(account, value)
    case value.value
      when Subledger::Domain::Zero
        "#{number_to_currency value.amount}".html_safe

      when Subledger::Domain::Credit
        "<i class='icon-arrow-up'></i> #{number_to_currency value.amount}".html_safe

      else
        "<i class='icon-arrow-down'></i> #{number_to_currency value.amount}".html_safe
    end
  end
end
