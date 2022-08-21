module SubmissionsHelper
  
  def extractable_metadatum_tooltip(options = {})
    help_tooltip(options[:content], {}, 'fas fa-file-export', 'extractable-metadatum', options[:text]).html_safe
  end


  def attribute_infos(attr_label)
    @metadata.select{ |attr_hash| attr_hash["attribute"].to_s.eql?(attr_label) }.first
  end

  def attribute_help_text(attr)

    if !attr["namespace"].nil?
      help_text = "&lt;strong&gt;#{attr["namespace"]}:#{attr["attribute"]}&lt;/strong&gt;"
    else
      help_text = "&lt;strong&gt;bioportal:#{attr["attribute"]}&lt;/strong&gt;"
    end

    if (attr["metadataMappings"] != nil)
      help_text << " (#{attr["metadataMappings"].join(", ")})"
    end

    if (!attr["enforce"].nil? && attr["enforce"].include?("uri"))
      help_text << "&lt;br&gt;This metadata should be an &lt;strong&gt;URI&lt;/strong&gt;"
    end

    if (attr["helpText"] != nil)
      help_text << "&lt;br&gt;&lt;br&gt;#{attr["helpText"]}"
    end
    help_text
  end
  # Generate the HTML label for every attributes
  def generate_attribute_label(attr_label)
    # Get the attribute hash corresponding to the given attribute
    attr = attribute_infos(attr_label)
    label_html = if !attr["extracted"].nil? && attr["extracted"] == true
      extractable_metadatum_tooltip({ content: 'Extractable metadatum' })
    end.to_s.html_safe

    if !attr["label"].nil?
      label_html << label_tag("submission_#{attr_label}", attr["label"], { class: 'form-label' })
    else
      label_html << label_tag("submission_#{attr_label}", attr_label.underscore.humanize, { class: 'form-label' })
    end

    # Generate tooltip
    help_text = attribute_help_text(attr)
    label_html << help_tooltip(help_text, {:id => "tooltip#{attr["attribute"]}"}).html_safe
    label_html
  end

  # Generate the HTML input for every attributes.
  def generate_attribute_input(attr_label, options = {})
    input_html = ''.html_safe
    
    # Get the attribute hash corresponding to the given attribute
    attr = @metadata.select{ |attr_hash| attr_hash["attribute"].to_s.eql?(attr_label) }.first
    
    if attr["enforce"].include?("integer")
      number_field "submission[#{@ontology.acronym}_onto_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym, value: @submission.send(attr["attribute"]), class: 'metadataInput form-control'

    elsif attr["enforce"].include?("date_time")
      field_id = [:submission, attr["attribute"].to_s, @ontology.acronym].join('_')
      date_value = @submission.send(attr["attribute"]).presence      
      content_tag(:div, class: 'input-group') do
        [
          text_field("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym, value: date_value, id: field_id, :data=> {controller: "flatpickr", flatpickr_date_format: "Y-m-d"})
        ].join.html_safe
      end

    elsif attr["enforce"].include?("textarea")
      text_area("submission[#{@ontology.acronym}_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym , rows: 3, value: @submission.send(attr["attribute"]), class: 'metadataInput form-control')

    # Create select dropdown when there are enforcedValues for the attr. But also let the user enter its own value if Other selected
    elsif !attr["enforcedValues"].nil?
      metadata_values = @submission.send(attr["attribute"])
      select_values = attr["enforcedValues"].collect{ |k, v| [v,k]}
      # Add in the select ontologies that are not in the portal but are in the values
      if metadata_values.kind_of?(Array)
        metadata_values.map do |metadata|
          if !select_values.flatten.include?(metadata)
            select_values << metadata
          end
        end
      else
        if (!select_values.flatten.include?(metadata_values) && !metadata_values.to_s.empty?)
          select_values << metadata_values
        end
      end

      if attr["enforce"].include?("list")
        input_html << content_tag(:div, "data-controller" => "select", "data-attribut"=>attr["attribute"] + "_" + @ontology.acronym) do
          concat select_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][#{attr["attribute"]}]", options_for_select(select_values, metadata_values), :multiple => 'true',
          "data-placeholder".to_sym => "Select ontologies", :style => "margin-bottom: 15px; width: 100%;", :id => "select_#{attr["attribute"]}_#{@ontology.acronym}", :class => "selectOntology", :data=> {action: "select#multipleSelect", attribut: @selected_metadata_to_edit, "select-target": "selectedOntologies"})
          concat text_field_tag("add_#{attr["attribute"].to_s}_#{@ontology.acronym}", nil, :style => "margin-right: 1em;width: 16em;display: inline;", :placeholder => "Or provide the value",
          :onkeydown => "if (event.keyCode == 13) { addValueToSelect('#{attr["attribute"]}'); return false;}", :class => 'metadataInput form-control', "data-select-target"=> "inputOntoField")
          concat button_tag("Add new value", :id => "btnAdd#{attr["attribute"]}_#{@ontology.acronym}",
          :type => "button", :class => "btn btn-primary btn-sm add-value-btn","data-action"=>"click->select#addOntoToSelect")
        end  

      else

        select_values << ["None", ""]
        select_values << ["Other", "other"]

        if metadata_values.nil?
          metadata_values = ""
        end

        

        # Button and field to add new value (that are not in the select). Show when other is selected
        input_html << content_tag(:div, :data=> {controller: "select ", attribut: attr["attribute"] + "_" + @ontology.acronym}) do
          concat select_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][#{attr["attribute"]}]", options_for_select(select_values, metadata_values), {:class => "form-control", :id => "select_#{attr["attribute"]}_#{@ontology.acronym}", :style=> "margin-bottom: 1em;", :data=> {action: "select#toggleOtherValue", attribut: @selected_metadata_to_edit, check: attr["attribute"] + "_" + @ontology.acronym, "select-target": "selectedValues"}})
          concat text_field_tag("add_#{attr["attribute"].to_s}_#{@ontology.acronym}", nil, :style => "margin-right: 1em;width: 16em;display: none;", :placeholder => "Or provide the value",
          :onkeydown => "if (event.keyCode == 13) { addValueToSelect('#{attr["attribute"]}'); return false;}", :class => 'metadataInput form-control', "data-select-target"=> "inputValueField")
          concat button_tag("Add new value", :id => "btnAdd#{attr["attribute"]}_#{@ontology.acronym}",
          :type => "button", :class => "btn btn-primary btn-sm add-value-btn", "data-action"=>"click->select#addValueToSelect","data-select-target": "btnValuefield",:style => "display: none;")
        end
      end


      return input_html


    elsif attr["enforce"].include?("isOntology")
      metadata_values = @submission.send(attr["attribute"])
      select_values = ontologies_for_select.dup
      # Add in the select ontologies that are not in the portal but are in the values
      if metadata_values.kind_of?(Array)
        metadata_values.map do |metadata|
          if !select_values.flatten.include?(metadata)
            select_values << metadata
          end
        end
      else

        if !select_values.flatten.include?(metadata_values)
          select_values << metadata_values
        end
      end
      input_html << content_tag(:div, "data-controller" => "select", "data-attribut"=>attr["attribute"] + "_" + @ontology.acronym) do
        if attr["enforce"].include?("list")
          concat select_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][#{attr["attribute"]}]", options_for_select(select_values, metadata_values), :multiple => 'true',
          "data-placeholder".to_sym => "Select ontologies", :style => "margin-bottom: 15px; width: 100%;", :id => "select_#{attr["attribute"]}_#{@ontology.acronym}", :class => "selectOntology", :data=> {action: "select#multipleSelect", attribut: @selected_metadata_to_edit, "select-target": "selectedOntologies"})
        else
          concat select_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][#{attr["attribute"]}]", options_for_select(select_values, metadata_values), "data-placeholder".to_sym => "Select ontology",
          :style => "margin-bottom: 15px; width: 100%;", :id => "select_#{attr["attribute"]}_#{@ontology.acronym}", :class => "selectOntology", :data=> {action: "select#multipleSelect", attribut: @selected_metadata_to_edit, "select-target": "selectedOntologies"})
        end  
        concat tag(:br)
        concat text_field_tag("add_#{attr["attribute"]}_#{@ontology.acronym}", nil, :style => "margin-right: 1em;vertical-align: super;width: 16em; display: inline",
                                   :placeholder => "Ontology outside of the Portal", :onkeydown => "if (event.keyCode == 13) { addOntoToSelect('#{attr["attribute"]}'); return false;}", :class => 'metadataInput form-control', "data-select-target": "inputOntoField")
        concat button_tag("Add new ontology", :id => "btnAdd#{attr["attribute"]}#{@ontology.acronym}", :style => "margin-bottom: 2em;margin-top: 1em;",
                          :type => "button", :class => "btn btn-primary btn-sm", "data-action"=>"click->select#addOntoToSelect")
      end
      return input_html

    elsif attr["enforce"].include?("uri")
      if @submission.send(attr["attribute"]).nil?
        uri_value = ""
      else
        uri_value = @submission.send(attr["attribute"])
      end

      if attr["enforce"].include?("list")
        input_html << content_tag(:div, "data-controller" => "select", "data-attribut"=>attr["attribute"] + "_" + @ontology.acronym, "data-inputtype"=>"url", "data-select-target" => "input") do
          concat button_tag("Add new value", :id => "add#{attr["attribute"]}_#{@ontology.acronym}",
                    :type => "button", :class => "btn btn-primary btn-sm add-value-btn", "data-action"=>"click->select#addInput")
          concat url_field_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][]", uri_value[0], :id => attr["attribute"].to_s + "_" + @ontology.acronym, class: "metadataInput form-control")
        end
        # Add field if list of URI
        if !@submission.send(attr["attribute"]).nil? && @submission.send(attr["attribute"]).any?
          @submission.send(attr["attribute"]).each_with_index do |metadata_val, index|
            if index != 0
              input_html << url_field_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][]", metadata_val, :id => "submission_#{attr["attribute"].to_s}" + "_" + @ontology.acronym, class: "metadataInput form-control")
            end
          end
        end
        input_html << content_tag(:div, "", id: "#{attr["attribute"]}Div")
      else
        # if single value
        input_html << text_field("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym, value: uri_value, class: "metadataInput form-control")    
      end
      return input_html

    elsif attr["enforce"].include?("boolean")
      input_html << content_tag(:div, class: "custom-control custom-switch") do 
        if !@submission.send(attr["attribute"])
          concat content_tag(:input, nil, :type => 'checkbox', :class => "custom-control-input", :id=>"customSwitch2")
          concat label_tag("", "", { class: 'custom-control-label', for: "customSwitch2" })
        else
          concat content_tag(:input, nil, :checked=> "checked", :type => 'checkbox', :class => "custom-control-input", :id=>"customSwitch2")
          concat label_tag("", "", { class: 'custom-control-label', for: "customSwitch2" })
        end
      end
      
    else
      # If input a simple text

      if attr["enforce"].include?("list")
        firstVal = ""
        if !@submission.send(attr["attribute"]).nil? && @submission.send(attr["attribute"]).any?
          firstVal = @submission.send(attr["attribute"])[0]
        end

        input_html << content_tag(:div, "data-controller" => "select", "data-attribut"=>attr["attribute"] + "_" + @ontology.acronym , "data-inputtype"=>"text", "data-select-target" => "input") do
          concat button_tag("Add new value", :id => "add#{attr["attribute"]}_#{@ontology.acronym}",
                                 :type => "button", :class => "btn btn-primary btn-sm add-value-btn", "data-action"=>"click->select#addInput")
          concat text_field_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][]", firstVal, :id => attr["attribute"].to_s + "_" + @ontology.acronym, class: "metadataInput form-control")
        end  

        # Add field if list of metadata
        if !@submission.send(attr["attribute"]).nil? && @submission.send(attr["attribute"]).any?
          @submission.send(attr["attribute"]).each_with_index do |metadata_val, index|
            if index != 0
              input_html << text_field_tag("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}][]", metadata_val, :id => "submission_#{attr["attribute"].to_s}_#{@ontology.acronym}", class: "metadataInput form-control")
            end
          end
        end

        input_html << content_tag(:div, "", id: "#{attr["attribute"]}_#{@ontology.acronym}Div")

      else
        # if single value text
        # TODO: For some reason @submission.send("URI") FAILS... I don't know why... so I need to call it manually
        if attr["attribute"].to_s.eql?("URI")
          input_html << text_field("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym, value: @submission.URI, class: "metadataInput form-control")
        else
          input_html << text_field("submission[#{@ontology.acronym}_onto_#{@submission.submissionId}]", attr["attribute"].to_s.to_sym, value: @submission.send(attr["attribute"]), class: "metadataInput form-control")
        end
      end
      return input_html
    end
  end


  def generate_attribute_text(attr_label , label)
    attr = attribute_infos(attr_label)
    label_html = "<div class='d-flex align-items-center'><span class='mr-1'>#{label}</span><span>"
    # Generate tooltip
    help_text = attribute_help_text(attr)
    label_html << help_tooltip(help_text, {:id => "tooltip#{attr["attribute"]}"} ).html_safe
    label_html << '</span></div>'
    label_html.html_safe
  end
  def ontologies_for_select
    @ontologies_for_select ||= LinkedData::Client::Models::Ontology.all.collect do |onto|
      ["#{onto.name} (#{onto.acronym})", onto.id]
    end
    
  end
  
end