class CreateCompanyRelativeSalers < ActiveRecord::Migration[5.1]
  def change
    create_table :company_relative_salers do |t|
      t.string :序号
      t.string :被考核科室
      t.string :生产经营绩效考核得分
      t.string :生产经营绩效考核扣分
      t.string :生产经营绩效考核_综合指标扣分
      t.string :生产经营绩效考核_设备质量扣分
      t.string :安全质量考核得分
      t.string :安全质量考核扣分
      t.string :安全质量考核_牌卡检查问题考核扣分
      t.string :工作质量考核_得分
      t.string :工作质量考核_平均扣分
      t.string :备注
      t.string :upload_year
      t.string :upload_month
      t.timestamps
    end
  end
end
