class EmpBasicInfo < ActiveRecord::Base
  belongs_to :employee
  belongs_to :workshop
  belongs_to :group
end
