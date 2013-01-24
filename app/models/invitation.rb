class Invitation < ActiveRecord::Base
  include ::SharedMethods::Paging
  include ::SharedMethods::SerializationConfig
  include ::SharedMethods


  def self.exposed_methods
    []
  end

  def self.exposed_attributes
    []
  end

  def self.exposed_associations
    []
  end

  def self.load_invitations(params = {})
    paging_info = parse_paging_options(params)
    self.paginate(
      :page => paging_info.page_id,
      :per_page => paging_info.page_size,
      :order => paging_info.sort_string )
  end

  def self.new_invitation(email)
    #check format, uniq (da check dc removed?)
    begin
      token = ActiveSupport::SecureRandom.hex(16)
    end while self.check_uniq_token(token)
    inv = Invitation.new({ :email => email, :token => token })
  end

  protected
    def self.parse_paging_options(options, default_opts = {})
      if default_opts.blank?
        default_opts = {
          :sort_criteria => "invitations.created_at DESC"
        }
      end
      paging_options(options, default_opts)
    end

    def self.check_uniq_token(token)
      Invitation.exists?({:token => token.to_s})
    end
end
