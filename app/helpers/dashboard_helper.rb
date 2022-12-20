module DashboardHelper

  def greet
    case Time.zone.now.hour
    when 4..11 then I18n.t('buenos_dias')
    when 12..19 then I18n.t('buenas_tardes')
    when 20..23 then I18n.t('buenas_noches')
    else
      I18n.t('hola')
    end
  end

end