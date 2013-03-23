class Admin::InvitesController < Admin::AdminController
  def index
    @inv_requests = Invitation.requested.paginate_and_sort(filtered_params)
  end

  def confirm_request
    params[:ids].each do |id|
      invitation_request = Invitation.find(id)
      invitation_request.invite!
    end

    emails = render_to_string(
      partial: 'emails_for_invite',
      locals: { emails: Invitation.requested.paginate_and_sort(filtered_params) }
    )

    render json: { success: true, emails: emails }

  rescue ActiveRecord::RecordNotFound
    render json: { msg: 'This request does not exist anymore.' }
  end

  def send_invitation
    if params[:inv][:emails].present?
      params[:inv][:emails].split(',').each do |email|
        Invitation.transaction do
          inv = Invitation.where(email: email).first_or_create(message: params[:inv][:message])
          inv.invite!
        end
      end
      result = { success: true, msg: 'Invite(s) sent!' }
    else
      result = { msg: 'Enter at least one email address' }
    end

    render json: result
  end

  protected

    def set_current_tab
      @current_tab = 'invites'
    end
end
