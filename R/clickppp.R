#' Dominic Schuhmacher's idea
#'
#' $Revision: 1.16 $ $Date: 2017/01/07 09:24:04 $
#'

clickppp <- local({

  clickppp <- function(n=NULL, win=square(1), types=NULL, ...,
                     add=FALSE, main=NULL, hook=NULL) {
    win <- as.owin(win)
    instructions <-
      if(!is.null(n)) paste("click", n, "times in window") else
      paste("add points: click left mouse button in window\n",
            "exit: press ESC or another mouse button")
    if(is.null(main))
      main <- instructions
  
    ####  single type #########################
    if(is.null(types)) {
      plot(win, add=add, main=main, invert=TRUE)
      if(!is.null(hook))
        plot(hook, add=TRUE)
      if(!is.null(n))
        xy <- spatstatLocator(n=n, ...)
      else
        xy <- spatstatLocator(...)
      #' check whether all points lie inside window
      if((nout <- sum(!inside.owin(xy$x, xy$y, win))) > 0) {
        warning(paste(nout,
                      ngettext(nout, "point", "points"),
                      "lying outside specified window; window was expanded"))
        win <- boundingbox(win, xy)
      }
      X <- ppp(xy$x, xy$y, window=win)
      return(X)
    }
  
    ##### multitype #######################
    
    ftypes <- factor(types, levels=types)
    #' input points of type 1 
    X <- getem(ftypes[1L], instructions, n=n, win=win, add=add, ..., pch=1)
    X <- X %mark% ftypes[1L]
    #' input points of types 2, 3, ... in turn
    naughty <- FALSE
    for(i in 2:length(types)) {
      Xi <- getem(ftypes[i], instructions, n=n, win=win, add=add,
                  ..., hook=X, pch=i)
      Xi <- Xi %mark% ftypes[i]
      if(!naughty && identical(Xi$window, win)) {
        #' normal case
        X <- superimpose(X, Xi, W=win)
      } else {
        #' User has clicked outside original window.
        naughty <- TRUE
        #' Use bounding box for simplicity
        bb <- boundingbox(Xi$window, X$window)
        X <- superimpose(X, Xi, W=bb)
      } 
    }
    if(!add) {
      if(!naughty)
        plot(X, main="Final pattern")
      else {
        plot(X$window, main="Final pattern (in expanded window)", invert=TRUE)
        plot(win, add=TRUE, invert=TRUE)
        plot(X, add=TRUE)
      }
    }
    return(X)
  }

  getem <- function(i, instr, ...) {
    main <- paste("Points of type", sQuote(i), "\n", instr)
    do.call(clickppp, resolve.defaults(list(...), list(main=main)))
  }

  clickppp
})


clickdist <- function() {
  a <- spatstatLocator(2)
  return(pairdist(a)[1L,2L])
}
