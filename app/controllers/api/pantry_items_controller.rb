module Api
  class PantryItemsController < BaseController
    def index
      items = PantryItem.order(:name).pluck(:id, :name).map { |id, name| { id: id, name: name } }
      render json: items
    end

    def create
      name = params[:name].to_s.downcase.strip
      item = PantryItem.create!(name: name)
      render json: { id: item.id, name: item.name }, status: :created
    end

    def destroy
      PantryItem.find(params[:id]).destroy
      head :no_content
    end
  end
end
