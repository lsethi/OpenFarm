class CropsController < ApplicationController
  after_action :verify_authorized, except: [:index, :new, :show, :create]
  def index
    @crops = Crop.all
    redirect_to(controller: 'crop_searches', action: 'search')
  end

  def new
    @crop = Crop.new(name: params[:name])
  end

  def show
    @crop = Crop.find(params[:id])
    @guides = @crop.guides
  end

  def create
    @crop = Crop.new(crops_params)
    if @crop.save
      redirect_to(controller: 'guides', action: 'new',
                  crop_id: @crop.id)
    else
      render :new
    end
  end

  def edit
    @crop = Crop.find(params[:id])
    authorize @crop
  end

  def update
    @crop = Crop.find(params[:id])
    authorize @crop
    @outcome = Crops::UpdateCrop.run(params[:crop],
                                     id: params[:id],
                                     crop: @crop,
                                     user: current_user)
    if @outcome.success?
      @crop.reload
      redirect_to(action: 'show', id: @crop.id)
    else
      puts @outcome.errors.message
      @crop.reload
      render :edit
    end
  end

  private
  def crops_params
    params.require(:crop).permit(:name, :binomial_name, :description,
              :sun_requirements, :sowing_method, :spread, :days_to_maturity,
              :row_spacing, :height)
  end
end
