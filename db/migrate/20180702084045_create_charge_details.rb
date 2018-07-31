class CreateChargeDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :charge_details, comment: "考核扣款明细表" do |t|
       t.string :序号
       t.string :科室车间
       t.integer :扣款合计
       t.integer :安全业绩扣款
       t.integer :生产经营绩效扣款
       t.integer :总重吨公里扣款
       t.integer :综合指标扣款
       t.integer :设备质量扣款
       t.integer :盈亏结果扣款
       t.integer :安全质量扣款
       t.integer :安全质量考核中牌卡扣分
       t.integer :安全质量考核中牌卡扣款
       t.integer :工作质量扣款
       t.integer :抽考扣款
       t.integer :红牌中层扣款
       t.integer :处分扣款
       t.integer :其他扣款
       t.integer :挂钩考核扣款
       t.float :安全业绩扣分, limit: 24
       t.float :总重吨公里扣分, limit: 24
       t.float :综合指标扣分, limit: 24
       t.float :设备质量扣分, limit: 24
       t.float :盈亏结果扣分, limit: 24
       t.float :安全质量扣分, limit: 24
       t.float :工作质量扣分, limit: 24
       t.timestamps
    end
  end
end
