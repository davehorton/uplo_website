class Admin::InvitesController < Admin::AdminController
  def index
    @inv_requests = Invitation.requested.paginate_and_sort(filtered_params)
  end

  def confirm_request
    params[:ids].each do |id|
      invitation_request = Invitation.find_by_id(id)

      if invitation_request.nil?
        result = { msg: 'This request does not exist anymore.' }
      else
        invitation_request.invite!
        result[:success] = true

        emails = render_to_string :partial => 'emails_for_invite',
          :locals => { :emails => Invitation.requested.paginate_and_sort(filtered_params) }
        result = { :success => true, :emails => emails }
      end
    end

    render(json: result)
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
        emails.each do |email|
          inv = Invitation.create(email: email, message: params[:inv][:message])
          inv.invite!
          invs << inv.id
          result = { :success => true, :msg => 'Invitations have been sent!' }
        end
      end
    end

    render :json => result
  end

  protected

    def set_current_tab
      @current_tab = 'invites'
    end
end
