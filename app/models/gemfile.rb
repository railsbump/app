class Gemfile < ApplicationRecord
  include HasCompats

  has_many :dependencies, class_name: 'GemfileDependency', dependent: :destroy
  has_many :gemmies, through: :dependencies

  validates :content, presence: true
  validates :slug,    presence: { if: -> { content.present? } }, uniqueness: { allow_blank: true }
  validates :gemmies, presence: { if: -> { content.present? } }

  delegate :to_param, to: :slug
end

# == Schema Information
#
# Table name: gemfiles
#
#  id         :bigint           not null, primary key
#  content    :text
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
