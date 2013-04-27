module Blastcat
  class BlastJob
    include SuckerPunch::Job
    workers 4

    def perform(id, file, opts)
      Blastcat.logger.info { "Blasting result #{ id }" }
      FileUtils.touch("./tmp/blasts/#{ id }")
      blast = BlastCommander::Blast.new(file, opts)

      Blastcat.logger.info { "Getting hits for #{ id }" }
      blast.hits

      Blastcat.logger.info { "Writing results for #{ id }" }
      File.open("./tmp/blasts/#{ id }", 'w') { |f| f.write(Marshal.dump(blast)) }

      Blastcat.logger.info { "Results for blast #{ id } are ready!" }
    end
  end
end
