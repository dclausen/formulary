module Formulary
  class BootstrapV3 < View
    def render
      concat(content_tag(:form, name: @form.name, action: @form.action, method: @form.method.upcase) do
        @form.model.each do |attr|
          concat(content_tag(:div, class: "form-group") do
            concat(content_tag(:label, attr[:name].to_s.humanize, for: attr[:name]))
            concat(field(attr))
          end)
        end
      end)

      # make it pretty!
      HtmlBeautifier.beautify(output_buffer)
    end

    def field(attr)
      case attr[:type]
      when :text
        tag(:input, type: :text, class: "form-control", id: attr[:name])
      when :textarea
        content_tag_string(:textarea, attr[:options].dig(:content), { class: "form-control", rows: attr[:rows], name: attr[:name] })
      else
        raise "invalid attribute type"
      end
    end
  end
end
