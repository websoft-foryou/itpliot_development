module ApplicationHelper

  def embed_remote_image(evaluation,key,chart_type)
    asset = evaluation.pdf_assets.where(key: key,chart_type: chart_type).first
    asset.img_string if asset
  end

  def format_datetime_to_local(datetime)
    l(datetime.in_time_zone(current_timezone), format: :short)
  end

  def format_num(num, unit = '', strip0 = false, precision = 2)
    number_to_currency(num, unit: unit, strip_insignificant_zeros: strip0, format: "%n %u", precision: precision)
  end

  def yes_no_label(text,b = nil)
    if b === true
      text = "<span class='label label-danger'> #{text} </span>"
    elsif b === false
      text = "<span class='label label-success'> #{text} </span>"
    end
    text.html_safe
  end

  def yes_no_check(val,numeric = false, has_link = true)
    check_class = has_link ? 'text-success' : 'text-muted'
    if numeric
      val = val > 0 ? true : false
    end
    if val
      out = '<i class="fa fa-check fa-lg ' + check_class + '"></i>'
    else
      out = '<i class="fa fa-minus text-muted"></i>'
    end
    out.html_safe
  end

  def label_danger(text)
    "<sup><span class='label label-danger'> #{text} </span></sup> &nbsp;".html_safe
  end

  def dataset_info(customer)
    s = ''
    drafts = customer.customer_evaluations.order("created_at desc").drafts
    published = customer.customer_evaluations.order("created_at desc").published
    if drafts.any?
      s += "<span class='text-emph'>#{drafts.first.name} (#{t('evaluations.draft')})</span>" 
      if published.any?
        s += "<br/><small>+ #{published.size} #{t('evaluations.more_saved')}</small>"
      end
    elsif published.any?
      s += "<span class='text-emph'>#{published.first.name} (#{t('evaluations.published')})</span>"
      if published.size > 1
        rest = published.size.to_i - 1
        s += "<br/><small>+ #{rest} #{t('evaluations.more_saved')}</small>"
      end

    end
    s.html_safe
  end

  def flash_messages
    r = []
    if flash[:notice].present?
      r << [content_tag( :div, id: "flash_success", class: "alert alert-success flash_success" )do 
        content_tag( :i, "", class: "fa fa-check fa-lg" ) +
        content_tag( :span, flash[:notice])
      end]
    end
    if flash[:error].present?
      r << [content_tag( :div, id: "flash_error", class: "alert alert-danger alert-block" )do 
        content_tag( :h4 ) do 
          content_tag( :i, "", class: "fa fa-ban fa-lg" ) + t("commons.error")
        end +
        content_tag( :p, flash[:error])
      end]
    end
    if flash[:alert].present?
      r << [content_tag( :div, id: "flash_error", class: "alert alert-warning alert-block" )do 
        content_tag( :h4 ) do 
          content_tag( :i, "", class: "fa fa-bell-o" ) + t("commons.warning")
        end +
        content_tag( :p, flash[:alert])
      end]
    end
    if flash[:info].present?
      r << [content_tag( :div, id: "flash_error", class: "alert alert-info" )do 
        content_tag( :p, flash[:info])
      end]
    end
    content_tag( :section, class: "container") do
      content_tag :div, r.join.html_safe, id: "flash_messages", class: "container", data: {spy: "affix", offset_top:"50"}
    end
  end

  def breadcrumb options={}
    icons = {
      themes: 'cube', theme: 'cube', 
      companies: 'globe',company: 'building-o', 
      resellers: 'users', reseller: 'user', 
      customers: 'building', customer: 'building-o', 
      businesses: 'briefcase', business: 'business',
      users: 'users', user: 'user',
      processes: 'puzzle-piece', processe: 'puzzle-piece',
      services: 'share-alt', service: 'share-alt-o',
      industries: 'industry', industry: 'industry',
      location: 'bullseye',
      evaluation: 'table'
    }
    list = []
    if options[:links].present?
        links = options[:links].delete_if{|a| a.nil? || a[:key].nil? }
        links.each do |crumb|
          next unless crumb[:name]
          list << content_tag(:li) do 
            content_tag(:i, "", class: "fa fa-#{icons[crumb[:key].to_sym]}") +
            if crumb == links.last || crumb[:url].blank?
              content_tag(:span, crumb[:name])
            else
              link_to( crumb[:name], crumb[:url] ).html_safe
            end
          end
        end
    end

    list.insert 0, content_tag(:li, class: "home"){ 
      content_tag(:i, "", class: "fa fa-dashboard") +
      link_to( t('commons.dashboard'), root_path ).html_safe
    }

    content_tag( :ol, class: "breadcrumb" ){ list.join.html_safe }
  end


  def browser_locale
    if Array.isArray(navigator.languages) && navigator.languages.length > 0 && navigator.languages[0]
        locale = navigator.languages[0]
    elsif navigator.language
        locale = navigator.language
    elsif navigator.browserLanguage
        locale = navigator.browserLanguage
    elsif navigator.userLanguage
        locale = navigator.userLanguage
    end
    #locale.startsWith('de') ? 'de' : 'en'
    locale
  end
end
