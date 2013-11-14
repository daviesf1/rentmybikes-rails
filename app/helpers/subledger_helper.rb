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

  def share_link
    url = request.original_url

    if user_signed_in? and not url.include?("token=")
      prefix = url.include?("?") ? "&" : "?"
      url += "#{prefix}token=#{current_user.authentication_token}"
    end

    "<a href='#{url}' target='_blank'>Share this!</a>".html_safe
  end
end
