class ShopItemsController < ApplicationController
  before_action :ensure_admin!

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

  def ensure_admin!
    unless current_user&.admin?
      redirect_to main_app.root_path, alert: "You are not authorized to access this page."
    end
  end

  def shop_item_params
    params.require(:shop_item).permit(
      :enabled,
      :ticket_cost,
      :usd_cost,
      :name,
      :desc,
      :one_per_person,
      :total_stock,
      :image
    )
  end
end
