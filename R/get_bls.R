get_bls <- function(){
  bls_location <- '~/Dropbox/relocation/Clean/bls.rds'
  if(!file.exists(bls_location)){
    # Do all the importing stuff
    
    
    
    
    saveRDS(bls_data, bls_location)
  } else {
    dt <- readRDS(bls_location)
  }
  return(dt)
}