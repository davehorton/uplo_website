module ProfilesHelper
  def user_possesive_form(user_id)
    if user_id == current_user.id
      'Your'
    else
      user = User.find_by_id user_id
      "#{user.try(:first_name)}'s"
    end
  end

  def user_pronoun(user_id)
    if user_id == current_user.id
      'You'
    else
      user = User.find_by_id user_id
      user.try(:first_name)
    end
  end
end
