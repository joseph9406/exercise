class Event < ApplicationRecord
    validates_presence_of :name # 宣告name這個屬性是必填。
end
