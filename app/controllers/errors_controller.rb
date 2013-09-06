class ErrorsController < ApplicationController
  skip_before_filter :authenticate_user!

  def not_found
    render :status => 404, :formats => [:html]
  end

end

