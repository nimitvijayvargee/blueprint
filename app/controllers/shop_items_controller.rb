class ShopItemsController < ApplicationController
  def new
    @shop_item = ShopItem.new
  end

  def create
    @shop_item = ShopItem.new(shop_item_params)

    if @shop_item.save
      redirect_to new_shop_item_path, notice: "Shop item created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def shop_item_params
    params.require(:shop_item).permit(
      :enabled,
      :ticket_cost,
      :usd_cost,
      :name,
      :desc,
      :one_per_person,
      :total_stock,
      :image,
      :type
    )
  end
end
