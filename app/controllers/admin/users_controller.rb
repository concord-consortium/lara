class Admin::UsersController < ApplicationController
  # GET /admin/users
  # GET /admin/users.json
  def index
    authorize! :manage, User
    page_options = { page: params[:page] || 1 , per_page: 200 }
    if q = params['q']
      q = "%#{q}%"
      @users = User.where("email like ?", q).paginate(page_options)
    else
      @users = User.paginate(page_options)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    @user = User.find(params[:id])
    authorize! :manage, @user

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/new
  # GET /admin/users/new.json
  def new
    @user = User.new
    @projects = Project.order(:title)
    authorize! :create, User

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /admin/users/1/edit
  def edit
    @user = User.find(params[:id])
    @projects = Project.order(:title)
    authorize! :update, @user
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(params[:user])
    authorize! :create, User

    respond_to do |format|
      if @user.save
        format.html { redirect_to edit_admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/users/1
  # PUT /admin/users/1.json
  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    if !params[:user][:admined_project_ids].present?
      params[:user][:admined_project_ids] = []
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to edit_admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_url }
      format.json { head :no_content }
    end
  end
end
