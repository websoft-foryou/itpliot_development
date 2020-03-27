module CompaniesHelper

  def company_contact_details(company)
    out = '<div class="co-details">'
      out += "<p><span><i class='fa fa-map-marker'></i></span> #{company.location.full_address}</p>" if company.location
      out += "<p><span><i class='fa fa-user-o'></i></span> #{company.contact_person}</p>" if company.contact_person
      out += "<p><span><i class='fa fa-phone'></i></span> #{company.phone}</p>" if company.phone
      out += "<p><span><i class='fa fa-mobile'></i></span> #{company.mobile}</p>"if company.mobile
      out += "<p><span><i class='fa fa-envelope-o'></i></span> #{company.email}</p>"if company.email
      out += "<p><span><i class='fa fa-external-link'></i></span> #{company.url}</p>"if company.url
      if company.business
        out += "<p><span><i class='fa fa-industry'></i></span> #{company.business.name}</p>"
      end
    out += '</div>'
    out.html_safe
  end

  def branch_inline_info(branch)
    description = branch.description
    city = branch.location.city if branch.location
    out = ''
    out = [description,city].compact.join('|')
    out = " <span class='text-muted'>(#{out})</span>" if out.present?
    out.html_safe
  end

  def companies_resellers_array
    out = []
    current_company.children.partner.each do |c|
      out << [c.name,c.id]
    end
    out
  end

  def companies_resellers_grouped
    out = []
    Company.jvp.each do |jvp|
      out << [jvp.name, jvp.children.partner.map {|p| [p.name, p.id]}]
    end
    out
  end

end
