require 'csv'

class TeamsController < ApplicationController

  before_filter :protect

  def index
    @teams = Team.all
  end

  def show
    @user = User.logged_in(session)
    @team = Team.find(params[:id])
  end

  def edit
    @team = Team.find(params[:id])
  end

  def update
    # Coursework
    CSV.parse(params[:team][:csv_crswrk]).each do |row|
      team = Team.find_by_name(row[0])
      next unless team
      i = 1
      team.deliverables.each do |del|
        if (row[i])
          del.update_attribute :mark, row[i]
          del.update_attribute :submitted, true
          if Integer(row[i]) < 0
            del.update_attribute :submitted, false
          end
        else
          del.update_attribute :mark, -1
        end
        i = i + 1
      end
      hi = HistoryItem.new(:submitted => true)
      hi.description = "MARKS UPDATED"
      hi.deliverable = nil
      hi.team = team
      hi.user = User.logged_in(session)
      hi.save
    end

    # Test
    CSV.parse(params[:team][:csv_test]).each do |row|
      user = User.find_by_k_number(row[0].upcase)
      next unless user
      user.update_attribute :test_mark_A, row[1]
      user.update_attribute :test_mark_B, row[2]
      user.update_attribute :test_mark, row[3]
    end


      redirect_to(teams_path, :notice => 'Marks successfully updated.')
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
    unless User.admin?(session) || User.logged_in(session).team_id == params[:id].to_i
      redirect_to User.logged_in(session)
      return false
    end
  end

end
