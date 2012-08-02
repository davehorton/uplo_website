class Admin::InvitesController < ApplicationController
  layout 'main'

  def index
    @inv_requests = Invitation.load_invitations(@filtered_params)
    # @inv_requests = Invitation.where('invited_at is null').load_invitations(@filtered_params)
  end

  def confirm_invitation_request
    inv = Invitation.find_by_id params[:id]
    if inv.nil?
      result = {:success => false, :msg => 'This request does not exist anymore.' }
    else
      inv.update_attribute(:invited_at, Time.now())
      #send email
      InvitationMailer.send_invitation(inv.id).deliver
      emails = render_to_string :partial => 'emails_for_invite',
        :locals => { :emails => Invitation.where('invited_at is null').load_invitations(@filtered_params) }
      result = { :success => true, :emails => emails }
    end
    render :json => result
  end

  def send_invitation
    req = Invitation.new_invitation(params[:email])
    if req.save
      #send email
      result = { :success => true }
    else
      result = { :success => true, :msg => req.errors.full_messages[0] }
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
