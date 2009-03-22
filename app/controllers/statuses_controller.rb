class StatusesController < ApplicationController
  before_filter :login_required, :except => [:user]

  # GET /statuses
  # GET /statuses.xml
  def index
    @statuses = current_user.statuses.active

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statuses }
    end
  end

  def user
    user = User.find_by_login(params[:id])
    if user
      @statuses = user.statuses.active
      render :action => 'index'
    else
      redirect_to '/'
    end
  end

  # GET /statuses/1
  # GET /statuses/1.xml
  def show
    @status = current_user.statuses.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @status }
    end
  end

  # GET /statuses/new
  # GET /statuses/new.xml
  def new
    @status = current_user.statuses.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @status }
    end
  end

  # GET /statuses/1/edit
  def edit
    @status = current_user.statuses.find(params[:id])
  end

  # POST /statuses
  # POST /statuses.xml
  def create
    @status = current_user.statuses.new(params[:status])

    respond_to do |format|
      if @status.save
        flash[:notice] = 'Status was successfully created.'
        format.html { redirect_to(@status) }
        format.xml  { render :xml => @status, :status => :created, :location => @status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /statuses/1
  # PUT /statuses/1.xml
  def update
    @status = current_user.statuses.find(params[:id])

    respond_to do |format|
      if @status.update_attributes(params[:status])
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to(@status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.xml
  def destroy
    @status = current_user.statuses.find(params[:id])
    @status.destroy

    respond_to do |format|
      format.html { redirect_to(statuses_url) }
      format.xml  { head :ok }
    end
  end
end
