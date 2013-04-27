require 'sinatra/base'

module Blastcat
  class Server < Sinatra::Base

    set :root, File.dirname(__FILE__)
    set :public_folder, Proc.new { File.join(root, './public') }
    enable :sessions
    set :session_secret, 'fea9528d1935bb80b14cdbc449e8bb43bb30b371'

    get '/' do
      session[:filter] = nil
      Blastcat.logger.info 'Welcome to Blastcat. Enter some sequences.'
      erb :index
    end

    get '/results/:id' do
      @id = params[:id]

      if File.size?("./tmp/blasts/#{ @id }")
        blast = Marshal.load(File.read("./tmp/blasts/#{ @id }"))
        @hits = blast.hits
      end

      erb :results
    end

    post '/results' do
      session[:filter] = nil
      session[:filter] = params[:filter] == '1'

      Blastcat.logger.debug "Remove uncultured? #{ session[:filter] }"
      Blastcat.logger.info 'Writing temporary sequences file'

      File.open('./tmp/sequences.fsa', 'w') do |file|
        file.write(params[:sequence])
      end

      Blastcat.logger.warn 'Blasting. This could take some time...'
      id = Time.now.to_i

      ::Blastcat::BlastJob.new.perform(id, './tmp/sequences.fsa', uncultured: session[:filter])

      redirect "/results/#{ id }"
    end

    post '/results/:id/csv' do
      Blastcat.logger.info 'Retrieving blast results'

      if File.size?("./tmp/blasts/#{ params[:id] }")
        blast = Marshal.load(File.read("./tmp/blasts/#{ params[:id] }"))
        @hits = blast.hits
      end

      @selected_hits = @hits.collect { |hit| hit if params[:export_hits].include?(hit.saccver) }.compact

      puts '--> Exporting CSV'

      csv_string = CsvShaper::Shaper.encode do |csv|
        csv.headers :sequence_id, :sequence, :accession_id, :definition, :hit_sequence, :length, :max_ident, :query_coverage, :evalue, :references

        csv.rows @selected_hits do |csv, hit|
          csv.cell :sequence_id, hit.qseqid
          csv.cell :sequence, hit.qseq
          csv.cell :accession_id, hit.saccver
          csv.cell :definition, hit.stitle
          csv.cell :hit_sequence, hit.sseq
          csv.cell :length, hit.slen
          csv.cell :max_ident, hit.pident
          csv.cell :query_coverage, hit.qcovs
          csv.cell :evalue, hit.evalue
          csv.cell :references, hit.references.collect { |ref| reference_formatter(ref) }.join(', ')#.gsub(',',' ')
        end
      end

      filename = "results-#{ Time.now.to_i }.csv"

      headers "Content-Disposition" => "attachment;filename=#{ filename }",
              "Content-Type" => "application/octet-stream"

      csv_string
    end

    def reference_formatter(ref)
      "#{ ref.authors } #{ ref.journal } #{ ref.description }"
    end

  end
end
