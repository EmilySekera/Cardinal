
#### Select a Region-of-Interest ####

setMethod("selectROI", "SparseImagingExperiment",
	function(object, ..., mode = c("region", "pixels"))
	{
		mode <- match.arg(mode)
		dots <- match.call(expand.dots=FALSE)$...
		if ( length(dots) > 0L ) {
			p <- image(object, ...)
			print(p)
		} else {
			p <- .Cardinal$lastplot
			if ( is.null(dev.list()) )
				print(p)
		}
		.selectROI(object, p, mode)
	})

setMethod("selectROI",
	signature = c(object = "SImageSet"),
	function(object, formula = ~ x * y,
		mode = c("region", "pixels"),
		...,
		main,
		subset = TRUE,
		lattice = FALSE)
	{
		mode <- match.arg(mode)
		if ( missing(main) )
			main <- paste("Select", mode)
		if ( lattice )
			.stop("selection is not supported for lattice graphics.")
		subset2 <- tryCatch(eval(substitute(subset), envir=pData(object),
			enclos=environment(formula)), error = function(e) eval(subset))
		image(object, formula=formula, ..., main=main, subset=subset2, lattice=lattice)
		model <- .parseImageFormula(formula, object=object, enclos=environment(formula))
		if ( length(subset2) < ncol(object) )
			subset2 <- rep(subset2, length.out=ncol(object))
		.message("select pixels and press ESC or second mouse button when done")
		if ( mode == "region" ) {
			loc <- locator(type="o", pch=20, col="white", lwd=1.5)
			if ( is.null(loc) ) return(NULL)
			coord <- coord(object)[subset2, names(model$right)]
			selected <- numeric(ncol(object))
			selected[subset2] <- point.in.polygon(coord[,1], coord[,2], loc$x, loc$y)
			selected <- selected > 0
			names(selected) <- pixelNames(object)
		} else {
			loc <- locator(type="p", pch=4, col="white")
			if ( is.null(loc) ) return(NULL)
			coord <- data.frame(round(loc$x), round(loc$y))
			names(coord) <- names(model$right)
			ok <- logical(ncol(object))
			ok[subset2] <- TRUE
			selected <- logical(ncol(object))
			selected[pixels(object, coord=coord)] <- TRUE
			selected <- selected & ok
			names(selected) <- pixelNames(object)
		}
		selected
	})

# selector functions

.selectROI <- function(object, plot, mode) {
	if ( is.null(dev.list()) )
		.stop("no open plot to use")
	title(sub="select pixels", col.sub="red")
	nruns <- nlevels(droplevels(run(object)[plot$subset]))
	if ( nruns > 1 )
		.warning("multiple runs plotted; results may be unexpected")
	.message("select pixels; press ESC or 2nd mouse button to stop")
	if ( mode == "region" ) {
		loc <- locator(type="o", pch=20, col="white", lwd=1.5)
		.selectRegion(loc, pixelData(object),
			subset=plot$subset, axs=plot$coordnames)
	} else {
		loc <- locator(type="p", pch=4, col="white")
		.selectPixels(loc, pixelData(object),
			subset=plot$subset, axs=plot$coordnames)
	}
}

.selectRegion <- function(loc, pdata, subset, axs = c("x", "y")) {
	roi <- rep(FALSE, nrow(pdata))
	coord <- coord(pdata)[subset,axs,drop=FALSE]
	selected <- point.in.polygon(coord[,1], coord[,2], loc$x, loc$y) > 0
	roi[subset] <- selected
	roi
}

.selectPixels <- function(loc, pdata, subset, axs = c("x", "y")) {
	pixels <- rep(FALSE, nrow(pdata))
	coord <- coord(pdata)[subset,axs,drop=FALSE]
	if ( !gridded(pdata) )
		.warning("pixel coordinates are not gridded")
	selected <- data.frame(round(loc$x), round(loc$y))
	names(selected) <- names(coord)
	coord$..i.. <- seq_len(nrow(coord))
	idx <- merge(coord, selected, by=axs)$..i..
	p <- rep(FALSE, nrow(coord))
	p[idx] <- TRUE
	pixels[subset] <- p
	pixels
}

# make a factor from logicals

makeFactor <- function(..., ordered = FALSE) {
	inds <- list(...)
	labs <- sapply(substitute(...()), deparse)
	if ( !is.null(names(inds)) ) {
		nz <- nzchar(names(inds))
		labs[nz] <- names(inds)[nz]
	}
	names(labs) <- NULL
	inds <- do.call("cbind", inds)
	inds <- apply(inds, 1, function(i) which(i)[1L])
	factor(labs[inds], levels=labs, ordered=ordered)
}
