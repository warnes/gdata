xlsFormats <- function(perl="perl", verbose=FALSE)
{
  if(verbose)
    message("Determining supported formats..")

  output <- runPerlScript("supportedFormats.pl", perl=perl, verbose=verbose)

  retval <- unlist( strsplit(output," "))
  retval <- retval[ -c(1,2) ]

  return(retval)
}
