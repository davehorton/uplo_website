module Admin::OrdersHelper
  def convert_to_edt(datetime)
    datetime.in_time_zone('Eastern Time (US & Canada)')
  end
end
