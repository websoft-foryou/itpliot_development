class AddDistinguishTypeColumnToEvaluation < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluations, :distinguish_type, :integer, default: Evaluation::TYPES.index(:normal)

    remove_column :evaluations, :is_sample if column_exists?(:evaluations, :is_sample)
  end
end
