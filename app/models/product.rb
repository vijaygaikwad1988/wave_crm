class Product < ActiveRecord::Base
  attr_accessible :description, :max_cost, :min_cost, :name, :company_id

  has_many :leads_products
  has_many :leads, :through => :leads_products
  belongs_to :company
end
