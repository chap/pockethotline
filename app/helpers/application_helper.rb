module ApplicationHelper
  def page_title
    
  end

  def active_button_class(button)
    button = button.split('#')
    "ui-btn-down-a" if controller.controller_name == button[0] && controller.action_name == button[1]
  end

  def active_link_to(text, url, condition = nil)
    if condition.nil? and String === url
      condition = url == request.path
    end
    content_tag :li, link_to(raw(text), url), :class => (condition && 'active')
  end

  def controller?(*names)
    names.find { |name| controller.controller_name == name.to_s }
  end
  
  def action?(*names)
    names.find { |name| controller.action_name == name.to_s }
  end

  def button_to_add_fields(name, f, new_object)
    fields =  render("user_fields", :f => f)
    link_to name, "#", :onclick => h("add_fields(this, \"user\", \"#{escape_javascript(fields)}\"); return false;"), :class => 'btn btn-success'
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, '#{association}', '#{escape_javascript(fields)}'); return false;".html_safe, :class => 'btn btn-success')
  end

  def add_http(link)
    if link.nil? || link.starts_with?('http://') || link.starts_with?('https://')
      link
    else
      "http://" + link
    end
  end
end
