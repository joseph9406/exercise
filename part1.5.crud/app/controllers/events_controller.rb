class EventsController < ApplicationController
  # 在進入控制器的主要動作之前(可以指定 actions),指定需要完成的前置處理工作。
  # 例如,驗證用戶的身份、檢查權限、設置變數或環境配置等。
  before_action :set_event, :only => [ :show, :edit, :update, :destroy]

  def index
    #@events = Event.all
    @events = Event.page(params[:page]).per(5)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:notice] = "event was successfully created"
      redirect_to :action => :index
    else
      render :action => :new
    end

    
  end

  def show
    @event = Event.find(params[:id])
    @page_title = @event.name
  end

  def edit
    @event = Event.find(params[:id])    
  end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      flash[:notice] = "event was successfully updated"
      redirect_to :action => :show, :id => @event
    else
      render :action => :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.destroy
      flash[:alert] = "event was successfully deleted"
    end

    redirect_to :action => :index
  end


  private 

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description)
  end
  

end
