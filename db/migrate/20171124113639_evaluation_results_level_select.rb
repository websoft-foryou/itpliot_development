class EvaluationResultsLevelSelect < ActiveRecord::Migration
  IMPACT_TYPES = [:unspecified, :none, :noticeable, :disruptive, :serious, :critical]

  def up
    add_column :evaluation_results, :impact_integer, :integer, :default => 0
    EvaluationResult.where("impact <> ''").each do |evaluation_result|
      evaluation_result.impact_integer = IMPACT_TYPES.index(evaluation_result.impact.downcase.parameterize.underscore) || 0
      evaluation_result.save!
    end
    remove_column :evaluation_results, :impact
    rename_column :evaluation_results, :impact_integer, :impact
  end

  def down
    add_column :evaluation_results, :impact_string, :string
    EvaluationResult.where("impact > 0").each do |evaluation_result|
      evaluation_result.impact_string = IMPACT_TYPES[evaluation_result.impact].to_s
      evaluation_result.save!
    end
    remove_column :evaluation_results, :impact
    rename_column :evaluation_results, :impact_string, :impact
  end

end
