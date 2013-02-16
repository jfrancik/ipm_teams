class DeliverablesController < ApplicationController

  before_filter :protect

  def edit
    redirect_to users_path if User.read_only?(session)
    @deliverable = Deliverable.find(params[:id])
    @deliverable.submitted = true
  end

  def update
    @deliverable = Deliverable.find(params[:id])
    if @deliverable.update_attributes(params[:deliverable])

      hi = HistoryItem.new(:submitted => @deliverable.submitted)
      hi.description = "Contributions for deliverable #{@deliverable.index} changed to: #{@deliverable.contributions.collect {|x| x.submitted_score}.join('/')}"
      hi.deliverable = @deliverable
      hi.team = @deliverable.team
      hi.user = User.logged_in(session)
      hi.save

      redirect_to(@deliverable.team, :notice => 'Deliverable was successfully updated.')
    else
      render :action => "edit"
    end
  end

  private

  def protect
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "#{1.year.ago}"
    if !User.logged_in?(session)
      session[:protected_page] = request.request_uri
      redirect_to users_path, :notice => "Please login first"
      return false
    end
    deliverable = Deliverable.find(params[:id])
    unless User.admin?(session) || User.logged_in(session).team_id == deliverable.team_id
      redirect_to User.logged_in(session)
      return false
    end
  end

end
