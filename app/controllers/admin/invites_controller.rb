class Admin::InvitesController < ApplicationController
  layout 'main'

  def index
    # @inv_requests = Invitation.load_invitations(@filtered_params)
    @inv_requests = Invitation.where('invited_at is null').load_invitations(@filtered_params)
  end

  def confirm_invitation_request
    result = { :success => false }
    if params[:ids].blank?
      result[:msg] = 'There is not any request left!'
    else
      params[:ids].each { |id|
        inv = Invitation.find_by_id id
        if inv.nil?
          result = {:success => false, :msg => 'This request does not exist anymore.' }
        else
          inv.update_attribute(:invited_at, Time.now())
          #send email
          InvitationMailer.send_invitation(inv.id).deliver
        end
      }
      if result[:success]
        emails = render_to_string :partial => 'emails_for_invite',
          :locals => { :emails => Invitation.where('invited_at is null').load_invitations(@filtered_params) }
        result = { :success => true, :emails => emails }
      end
    end
    render :json => result
  end

  def send_invitation
    result = { :success => false }
    if !params[:inv].has_key?('emails') || params[:inv]['emails'].blank?
      result[:msg] = 'Input at least 1 email first!'
    else
      invs = []
      msg = ''
      Invitation.transaction do
        emails = params[:inv]['emails'].split(',')
        emails.each { |email|
          email.strip!
          # check email format & unique
          if (User::EMAIL_REG_EXP =~ email).nil?
            msg = "#{email} is invalid email!"
            raise ActiveRecord::Rollback
          elsif Invitation.exists?(:email => email) || User.exists?(:email => email)
            msg = "#{email} has been invited!"
            raise ActiveRecord::Rollback
          else
            inv = Invitation.new_invitation email.strip
            inv[:invited_at] = Time.now()
            inv.save(:validation => false)
            invs << inv.id
            result = { :success => true, :msg => 'Invitations have been sent!' }
          end
        }
      end

      if result[:success]
        invs.each { |id| InvitationMailer.send_invitation(id, params[:inv]['message']).deliver }
      elsif msg.blank?
        result[:msg] = 'Cannot invite any emails right now! Please try again later!'
      else
        result[:msg] = msg
      end
    end

    render :json => result
  end

  protected
    def set_current_tab
      @current_tab = 'invites'
    end

    def default_page_size
      return 10
    end
end
