ll <- function(pos=1, unit="KB", digits=0, dim=FALSE, sort=FALSE, class=NULL,
               invert=FALSE, standard="SI", ...)
{
  get.object.class <- function(object.name, pos)
  {
    object <- get(object.name, pos=pos)
    class(object)[1]
  }

  get.object.dim <- function(object.name, pos)
  {
    object <- get(object.name, pos=pos)
    if(class(object)[1] == "function")
      dim <- ""
    else if(!is.null(dim(object)))
      dim <- paste(dim(object), collapse=" x ")
    else
      dim <- length(object)
    dim
  }

  get.object.size <- function(object.name, pos)
  {
    object <- get(object.name, pos=pos)
    size <- try(unclass(object.size(object)), silent=TRUE)
    if(class(size) == "try-error")
      size <- 0
    size
  }

  ## 1  Set original.rank
  original.rank <- NULL

  ## 2  Detect what 'pos' is like, then get class, size, dim
  if(is.character(pos))  # pos is an environment name
    pos <- match(pos, search())
  if(isS4(pos))  # pos is an S4 object
    pos <- sapply(slotNames(pos), slot, object=pos, simplify=FALSE)
  if(is.list(pos))  # pos is a list-like object
  {
    if(is.null(names(pos)))
      stop("All elements of a list must be named")
    original.rank <- rank(names(pos))
    pos <- as.environment(pos)
  }
  if(length(ls(pos,...)) == 0)  # pos is an empty environment
  {
    object.frame <- data.frame()
  }
  else if(environmentName(as.environment(pos)) == "Autoloads")
  {
    object.frame <- data.frame(rep("function",length(ls(pos,...))),
                               rep(0,length(ls(pos,...))),
                               row.names=ls(pos,...))
    if(dim)
    {
      object.frame <- cbind(object.frame, rep("",nrow(object.frame)))
      names(object.frame) <- c("Class", unit, "Dim")
    }
    else
      names(object.frame) <- c("Class", unit)
  }
  else
  {
    class.vector <- sapply(ls(pos,...),
                           get.object.class, 
                           pos=pos)
    
    size.vector <- sapply(ls(pos,...), 
                          get.object.size, 
                          pos=pos)
    
    row.names <- names(size.vector)
    
    size.vector <- humanReadable(size.vector, 
                                 units=unit, 
                                 standard=standard, 
                                 digits=digits)
    
    object.frame <- data.frame(class.vector=class.vector,
                               size.vector=size.vector,
                               row.names=row.names)
    
    names(object.frame) <- c("Class", unit)
    
    if(dim)
      object.frame <- cbind(object.frame,
                            Dim=sapply(ls(pos,...),get.object.dim,pos=pos))
  }

  ## 3  Retain original order of list elements
  if(!sort && !is.null(original.rank))
    object.frame <- object.frame[original.rank,]

  ## 4  Filter results given class
  if(!is.null(class))
  {
    include <- object.frame$Class %in% class
    if(invert)
      include <- !include
    object.frame <- object.frame[include,]
  }

  object.frame
}
