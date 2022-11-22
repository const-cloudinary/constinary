class TransformationsController < ApplicationController
  def index
    @transformations = Transformation.all
  end

  def show
    @transformation = Transformation.find(params[:id])
  end

  def new
    @transformation = Transformation.new
  end

  def create
    @transformation = Transformation.new(transformation_params)

    if @transformation.save
      redirect_to @transformation
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def transformation_params
    params.require(:transformation).permit(:name, :tr_string)
  end
end