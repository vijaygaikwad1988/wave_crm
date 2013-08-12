class Product < ActiveRecord::Base
  attr_accessible :description, :max_cost, :min_cost, :name, :company_id

  has_one :inventory, :dependent => :destroy
  has_many :inventory_additions, :dependent => :destroy
  has_many :product_transactions, :dependent => :destroy
  has_many :transactions, :through => :product_transactions
  belongs_to :company

  validates :company_id, :presence => true
  validates :description, :presence => true
  validates :max_cost, :presence => true, :numericality => true
  validates :min_cost, :presence => true, :numericality => true
  validates :name, :presence => true, :uniqueness => {:scope => :company_id}

  after_save :create_empty_inventory

  def create_empty_inventory
      if self.inventory.nil?
          self.build_inventory(:company_id => self.company_id, :quantity => 0).save
      end

  end
end
