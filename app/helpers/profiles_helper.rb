module ProfilesHelper
  def user_possesive_form(user_id)
    if user_id == current_user.try(:id)
      'Your'
    else
      user = User.find_by_id user_id
      "#{user.try(:username)}'s"
    end
  end

  def following_header_label(user_id)
    if user_id == current_user.try(:id)
      'You Are Following'
    else
      user = User.find_by_id user_id
      "#{user.try(:username)} Is Following"
    end
  end
end
