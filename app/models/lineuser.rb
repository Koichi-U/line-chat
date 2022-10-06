class Lineuser < ApplicationRecord
  has_many :follows
  has_many :chats
end
