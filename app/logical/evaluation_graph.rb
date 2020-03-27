class EvaluationGraph
  require 'rgl/adjacency'
  require 'rgl/dot'

  BASE_PATH = "public/system/eval_graphs"

  def initialize evaluation
    @filename = evaluation.id.to_s
    @evaluation = evaluation
    unless File.exists?(File.join(Rails.root, BASE_PATH))
      FileUtils.mkdir_p(File.join(Rails.root, BASE_PATH))
    end
  end

  def draw_dependant
    dg=RGL::DirectedAdjacencyGraph[]
    @evaluation.active_evaluation_results.each do |r|
      r.result_depending_services.each do |d|
        dg.add_edge r.service.code, d.code
      end
      dg.write_to_graphic_file('png', File.join(BASE_PATH, @filename))
    end
  end

  def draw
    draw_dependant
  end

end
