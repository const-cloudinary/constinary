class PicturesController < ApplicationController
  attr_accessor :pictures_dir

  def initialize
    @pictures_dir = Dir.home + "/Pictures/"
  end

  def index
    @images = Dir.glob(@pictures_dir + "*.jpg")
  end

  def transform
    handle_params(params)
    unless File.exist? @full_path
      render "pictures/not_found", formats: :html
      return
    end

    Constinary.load(@full_path)
    image = Constinary.transform_the_image(@transformations)
    @the_data = image.save_data
    render formats: :html
  end

  protected

  def handle_params(params)
    parts = params["path"].split("/")
    actions, path_parts = parts.partition { |e| e.start_with?("@") }

    @full_name = [path_parts.join("/"), params["format"]].compact.join "."
    @full_path = @pictures_dir + @full_name

    @transformations = Constinary.handle_transformation_string(actions.join("/"))
  end
end
