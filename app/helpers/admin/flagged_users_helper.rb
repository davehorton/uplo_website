module Admin::FlaggedUsersHelper
  # Generate a mailto link for flagged users.
  #
  # === Parameters
  #
  #   * sender (String): email of the sender
  #   * flagged_users (User): list of flagged users will be sent mail.
  #   * options[:bcc] (True/False): determine to send BCC to flagged users. Default is False
  #   * options[:link_label] (String): label of the link. Default is "Contact User".
  #   
  def flagged_users_mail_link(flagged_users, options = {})
    if flagged_users.blank?
      return ""
    end
    
    if flagged_users.is_a?(User)
      # Convert to Array.
      flagged_users = [flagged_users]
    end
    
    # Prepare default options
    link_label = options.delete(:link_label)
    if link_label.nil?
      link_label = I18n.t("admin.contact_user")
    end
    
    is_bcc = options.delete(:bcc)
    
    email_addresses = []
    bcc_email_addresses = []
    
    flagged_users.each do |user|
      if is_bcc && !email_addresses.blank?
        bcc_email_addresses << user.email        
      else
        email_addresses << user.email
      end
    end

    email_addresses.uniq!
    bcc_email_addresses.uniq!
    
    email_addresses = email_addresses.join(",")
    bcc_email_addresses = bcc_email_addresses.join(",")
    
    options.merge!({
      :encode => "hex"
    })
    
    # Add BCC email.
    unless bcc_email_addresses.blank?
      options[:bcc] = bcc_email_addresses
    end
    
    mail_to(email_addresses, link_label, options)
  end
end
