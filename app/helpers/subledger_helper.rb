module SubledgerHelper
  def format_amount(account, value)
    case value.value
      when Subledger::Domain::Zero
        "#{number_to_currency value.amount}".html_safe

      when Subledger::Domain::Credit
        "#{image_tag('arrow_up.png')} #{number_to_currency value.amount}".html_safe

      else
        "#{image_tag('arrow_down.png')} #{number_to_currency value.amount}".html_safe
    end
  end
end
