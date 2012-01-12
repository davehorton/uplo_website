# CustomException for app
module CustomException
  class AccessDenied < Exception
    def initialize(msg = "")
      super(msg)
    end
  end
end
