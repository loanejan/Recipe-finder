class PantryItemsController < ApplicationController
  def index
    @items = PantryItem.order(:name)
  end

  def create
    name = params.dig(:pantry_item, :name).to_s.downcase.strip
    PantryItem.create!(name:) unless name.blank?
    redirect_to pantry_items_path
  end

  def destroy
    PantryItem.find(params[:id]).destroy
    redirect_to pantry_items_path
  end
end
