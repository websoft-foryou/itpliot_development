module HomesHelper
  def dashboard_box(link,text,icon)
    content_tag( :div, class: "col-lg-3 col-md-4 col-sm-6" ) do
      content_tag(:div, class: "dashboard-category") do
        link_to( link ) do
          content_tag(:i, "", class: "fa #{icon} fa-lg") +
          content_tag(:h3, text)
        end
      end
    end.html_safe
  end


  def dashboard_step_box(link,text,icon,status,alt)
    content_tag( :div, class: "col-lg-3 col-md-4 col-sm-6" ) do
      content_tag(:div, class: "dashboard-category #{status}") do
        link_to( link ) do
          content_tag(:i, "", class: "fa #{icon} fa-lg") +
          content_tag(:h3, text) +
          content_tag(:div,"#{alt}",class: "status")
        end
      end
    end.html_safe
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= current_user
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end