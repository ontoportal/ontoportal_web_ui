module SubmissionsHelper

  # Generate the HTML input for every attributes
  def generate_attribute_input(attr)
    input_html = ''.html_safe

    if attr["enforce"].include?("integer")
      number_field :submission, attr["attribute"].to_s.to_sym, value: @submission.send(attr["attribute"])

    elsif attr["enforce"].include?("date_time")
      if @submission.send(attr["attribute"]).nil?
        date_value = nil
      else
        date_value = DateTime.parse(@submission.send(attr["attribute"])).to_date.to_s
      end
      text_field :submission, attr["attribute"].to_s.to_sym, :class => "datepicker", value: "#{date_value}"

    elsif attr["enforce"].include?("uri")
      if @submission.send(attr["attribute"]).nil?
        uri_value = ""
      else
        uri_value = @submission.send(attr["attribute"])
      end
      input_html << url_field(:submission, attr["attribute"].to_s.to_sym, value: uri_value)

      if attr["enforce"].include?("list")
        input_html << button_tag("Add new value", :id => "add#{attr["attribute"]}", :style => "margin-bottom: 0.5em;margin-top: 0.5em;",
                                 :type => "button", :class => "btn btn-info", :onclick => "addInput('#{attr["attribute"]}', 'url')")
        input_html << content_tag(:div, "", id: "#{attr["attribute"]}Div")
        return input_html
      end
      return input_html

    elsif attr["enforce"].include?("boolean")
      select("submission", attr["attribute"].to_s, ["none", "true", "false"], { :selected => @submission.send(attr["attribute"])})

    else
      # If a simple text
      input_html << text_field(:submission, attr["attribute"].to_s.to_sym, value: @submission.send(attr["attribute"]))
      if attr["enforce"].include?("list")
        #input_html << content_tag(:br)
        input_html << button_tag("Add new value", :id => "add#{attr["attribute"]}", :style => "margin-bottom: 0.5em;margin-top: 0.5em;",
                                 :type => "button", :class => "btn btn-info", :onclick => "addInput('#{attr["attribute"]}', 'text')")
        input_html << content_tag(:div, "", id: "#{attr["attribute"]}Div")
      end
      return input_html
    end
  end

end