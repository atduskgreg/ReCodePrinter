require "./models"

desc "Import Pieces from JSON"
task :import do
	Piece.import_from_json!
end

desc "Get needed bitly links"
task :shorten_links do
	Piece.shorten_links!
end