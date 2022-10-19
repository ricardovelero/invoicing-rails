module DashboardHelper

  def greet
    case Time.zone.now.hour
    when 4..11 then 'Buenos días'
    when 12..19 then 'Buenas tardes'
    when 20..23 then 'Buenas noches'
    else
      '¡Hola!'
    end
  end

end