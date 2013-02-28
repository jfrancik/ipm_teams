require 'digest/sha2'
require 'csv'

class UsersController < ApplicationController

  respond_to :html, :csv

  before_filter :protect, :except => [:index, :new, :create, :activate, :login, :logout, :lost_password,
                                      :update_lost_password, :reset_password, :update_reset_password,
                                      :init, :history]

  # GET /users
  def index
    redirect_to User.logged_in(session) if User.logged_in?(session)
    @user = User.new
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  def all
    @user = User.logged_in(session)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # this is for registration of new users
  def create
    @user = User.new(params[:user])
    @user.team = Team.find_by_name(@user.assign_to_team)
    if @user.save

      # create user contributions
      if @user.team
        for i in 1..24 do
          con = Contribution.new
          if (@user.team.users.size > 3)
            con.score = 3
          else
            con.score = 4
          end
          con.user = @user
          con.deliverable = @user.team.deliverables.find_by_index(i)
          con.save :validate => false
        end
      end

      MyMailer.activation_email(@user, root_url).deliver
      render :action => "confirmation"
    else
      render :action => "new"
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to(@user, :notice => 'Account was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to(users_url)
  end

  def activate
    user = User.find_by_key(params[:key]) if params[:key] && !params[:key].empty?
    if user == nil
      redirect_to users_path, :notice => "Oops, we have no such account in our database... You may have already activated this account."
    else
      user.login!(session)
      redirect_to(user, :notice => 'You are now logged in')
    end
  end

  # POST /users/login
  def login
    user = User.find_by_k_number(params[:user][:k_number].upcase)
#    if user && !user.admin?
#      redirect_to(users_path, :notice => "Only ADMIN login now!")
    if !user || !user.authorised?(params[:user][:password])
      redirect_to(users_path, :notice => "Invalid K Number/Password combination")
    elsif !user.activated?
      redirect_to(users_path, :notice => "Account is not yet activated. Please check your e-mail box.")
    else
      user.login!(session)
      redirect_to(user, :notice => 'You are now logged in')
    end
  end

  def logout
    User.logout!(session)
    redirect_to(users_path)
  end

  def lost_password
    @user = User.new
  end

  def update_lost_password
    @user = User.find_by_k_number(params[:user][:k_number].upcase)
    if !@user
      redirect_to(lost_password_users_path, :notice => "Oops, we don't have this K Number in the database yet... Please register first.")
    elsif !@user.activated?
      redirect_to(lost_password_users_path, :notice => "Account is not yet activated. Please check your e-mail box.")
    else
      @user.reset_password!
      MyMailer.reset_email(@user, root_url).deliver
    end
  end

  def reset_password
    @user = User.find_by_key(params[:key]) if params[:key] && !params[:key].empty?
    if !@user
      redirect_to users_path, :notice => "Oops, we have no such account in our database... You may have already reset this password."
    end
  end

  def update_reset_password
    key = params[:user][:key]
    @user = User.find_by_key(key) if key && !key.empty?
    if @user == nil
      redirect_to users_path, :notice => "Oops, we have experienced an unexpected error. Please try reset your password again..."
    elsif @user.update_attributes(params[:user])
      @user.login!(session)
    else
      render :action => "reset_password"
    end
  end

  def init
    if User.logged_in?(session) && User.admin?(session)
      User.delete_all("privilege=0")
      Team.delete_all
      Deliverable.delete_all
      Contribution.delete_all
      HistoryItem.delete_all
      CSV.parse(File.read('users.csv')).each do |row|

        #create the user
        user = User.new(:k_number => row[0],
                         :first_name => row[1],
                         :last_name => row[2],
                         :password => "",
                         :privilege => 0,
                         :key => "",
                         :ver => true,
                         :salt => "",
                         :passwd_reset => false)

        user.k_number.capitalize!
        user.salt = SecureRandom.base64(8)
        user.password = Digest::SHA2.hexdigest((user.salt || "") + "salatkaprowansalska")

        # add (create) a team
        team = Team.find_by_name(row[3])
        unless team
          team = Team.new(:name => row[3])
          team.save :validate => false

          # create team's deliverables
          for i in 0..25 do
            del = Deliverable.new(:index => i)
            del.team = team
            del.submitted = false
            del.mark = -1
            del.save :validate => false
          end
    
        end
        user.team = team

        user.save :validate => false
      end

      User.all.each do |user|
        # create user contributions
        for i in 1..24 do
          next unless user.team
          con = Contribution.new
          if (user.team.users.size > 3)
            con.score = 3
          else
            con.score = 4
          end
          con.user = user
          con.deliverable = user.team.deliverables.find_by_index(i)
          con.save :validate => false
        end
      end

      redirect_to User.logged_in(session), :notice => "DATABASE RE-INITIALISED"
    else
      redirect_to users_path, :notice => "Please login with administrator priviliges"
    end
  end

  def email
    if User.logged_in?(session) && User.admin?(session)
      @user = User.find(params[:id]) if params[:id]
      if @user
        @user.reset_password!
        MyMailer.admin_welcome_email(@user, root_url).deliver
        redirect_to users_path, :notice => "E-mail sent to #{@user.e_mail}"
      else
        count = 10;
        User.all(:order => "id").each do |user|
          next if user.passwd_reset
          break if count <= 0
          count = count - 1
          user.reset_password!
          MyMailer.admin_welcome_email(user, root_url).deliver
        end
        redirect_to users_path, :notice => "Accounts e-mailed"
      end
    else
      redirect_to users_path, :notice => "Please login with administrator priviliges"
    end
  end

  def history
    if User.logged_in?(session) && User.admin?(session)
      @history = HistoryItem.all
    else
      redirect_to users_path, :notice => "Please login with administrator priviliges"
    end
  end

  def export
    if User.logged_in?(session) && User.admin?(session)
      @users = User.all
      headers.merge!({
                         'Cache-Control'             => 'must-revalidate, post-check=0, pre-check=0',
                         'Content-Type'              => 'text/csv',
                         'Content-Disposition'       => "attachment; filename=\"ipm_teams.csv\"",
                         'Content-Transfer-Encoding' => 'binary'
                     })
      render :layout => false, :format => "csv"
    else
      redirect_to users_path, :notice => "Please login with administrator priviliges"
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
    unless User.logged_in_id(session).to_i == params[:id].to_i || User.admin?(session)
      redirect_to User.logged_in(session)
      return false
    end
  end

end
