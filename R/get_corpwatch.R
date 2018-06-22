get_corpwatch <- function(){
  corpwatch_location <- '~/Dropbox/pkg.data/relocation/raw/corpwatch.csv.tar.gz'
  if(!(file.exists(corpwatch_location))){
    csv <- download.file('http://api.corpwatch.org/documentation/db_dump/corpwatch_api_tables_csv.tar.gz', corpwatch_location)
  }
  
}