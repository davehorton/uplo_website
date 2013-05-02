# any class or module referenced here requires stubbing (usually of network calls)
# in the actual spec test

class Gibbon
  def method_missing(action, *args)
    raise "You forgot to stub Gibbon##{action}"
  end
end
