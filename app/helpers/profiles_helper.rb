module ProfilesHelper
  def user_possesive_form(user_id)
    if user_id == current_user.id
      'Your'
    else
      user = User.find_by_id user_id
      "#{user.try(:first_name)}'s"
    end
  end

  def following_header_label(user_id)
    if user_id == current_user.id
      'You Are Following'
    else
      user = User.find_by_id user_id
      "#{user.try(:first_name)} Is Following"
    end
  end
end
