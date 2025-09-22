# == Schema Information
#
# Table name: shop_items
#
#  id             :bigint           not null, primary key
#  desc           :string
#  enabled        :boolean
#  name           :string
#  one_per_person :boolean
#  ticket_cost    :integer
#  total_stock    :integer
#  type           :string
#  usd_cost       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require "test_helper"

class ShopItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
