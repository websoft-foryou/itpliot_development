module ResourcesHelper
  def resource_activity_legend(activity)
    out = '<div class="custom_graph_labels">'
    colors = ['#56E2CF','#56AEE2','#5668E2','#8A56E2','#CF56E2','#E256AE','#E25668','#E22F05','#E28203','#E2B869','#E2D011','#ACE232']
    activity.each_with_index do |(k,v),idx|
      unless v.zero?
        out += "<span style='background:#{colors[idx]};width: 20px;height: 7px;display: inline-block;margin: 0px 4px 0px 10px;'></span>"
        out += k.upcase
      end
    end
    out += '</div>'
    out.html_safe
  end
end
