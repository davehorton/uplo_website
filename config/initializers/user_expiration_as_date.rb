User.instance_eval do
  # make string column behave like a date
  class << columns_hash['expiration']
    def type
      :date
    end
  end
end