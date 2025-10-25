# app/controllers/api/pantry_items_controller.rb
module Api
  class PantryItemsController < BaseController
    def index
      render json: PantryItem.order(:name).map { |item| serialize(item) }
    end

    def create
      item = PantryItem.create!(name: params[:name].to_s.downcase.strip)
      render json: serialize(item), status: :created
    end

    def destroy
      PantryItem.find(params[:id]).destroy
      head :no_content
    end

    private

      def serialize(item)
        { id: item.id, name: item.name }
      end
  end
end
