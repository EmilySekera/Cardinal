\name{SImageData-class}
\docType{class}

\alias{class:SImageData}
\alias{SImageData}
\alias{SImageData-class}

\alias{[,SImageData-method}
\alias{[,SImageData,ANY,ANY,ANY-method}
\alias{[,SImageData,ANY,ANY,NULL-method}
\alias{combine,SImageData,SImageData-method}
\alias{dim,SImageData-method}
\alias{dims,SImageData-method}
\alias{initialize,SImageData-method}
\alias{iData,SImageData,ANY-method}
\alias{iData<-,SImageData,ANY-method}
\alias{peakData,SImageData-method}
\alias{peakData<-,SImageData-method}
\alias{mzData,SImageData-method}
\alias{mzData<-,SImageData-method}
\alias{coord,SImageData-method}
\alias{coord<-,SImageData-method}
\alias{featureNames,SImageData-method}
\alias{featureNames<-,SImageData-method}
\alias{pixelNames,SImageData-method}
\alias{pixelNames<-,SImageData-method}
\alias{positionArray}
\alias{positionArray<-}
\alias{positionArray,SImageData-method}
\alias{positionArray<-,SImageData-method}
\alias{regeneratePositions}
\alias{regeneratePositions,SImageData-method}


\title{SImageData: Class containing sparse image data}

\description{
    A container class for holding pixel-sparse image as a virtual datacube. It is assumed there will be missing pixels, so the feature vectors are stored as a matrix for memory efficiency, and the datacube is reconstructed on-the-fly. The implementation remains efficient even for non-sparse data as long as the full datacube does not need to be reconstructed as often as single images and feature vectors. All elements of \code{data} must have an identical number of rows (features) and columns (pixels).
}

\usage{
## Instance creation
SImageData(
    data = Hashmat(nrow=0, ncol=0),
    coord = expand.grid(
        x = seq_len(ncol(data)),
        y = seq_len(ifelse(ncol(data) > 0, 1, 0))),
    storageMode = "immutableEnvironment",
    positionArray = generatePositionArray(coord),
    dimnames = NULL,
    \dots)

## Additional methods documented below
}

\arguments{
    
    \item{data}{A matrix-like object with number of rows equal to the number of features and number of columns equal to the number of non-missing pixels. Each column should be a feature vector. Alternatively, a multidimensional array that represents the datacube with the first dimension as the features can also be supplied. Additional dimensions could be the spatial dimensions of the image, for example.}

    \item{coord}{A \code{data.frame} with columns representing the spatial dimensions. Each row provides a spatial coordinate for the location of a feature vector corresponding to a column in \code{data}. This argument is ignored if \code{data} is a multidimensional array rather than a matrix.}

    \item{storageMode}{The storage mode to use for the \code{SImageData} object for the environment in the \code{data} slot. Only \code{"immutableEnvironment"} is allowed for \code{SImageData}. See documentation on the \code{storageMode} slot below for more details.}

    \item{positionArray}{The \code{positionArray} for the imaging data. This should not normally be specified the user, since it is generated automatically from the \code{coord} argument, unless for some reason \code{coord} is not specified.}

    \item{dimnames}{A \code{list} of length two, giving the feature names and pixel names in that order. If missing, this is taken from the 'dimnames' of the \code{data} argument.}

    \item{\dots}{Additional Named arguments that are passed to the \code{initialize} method for instantiating the object. These must be matrices or matrix-like objects of equal dimension to \code{data}. They will be assigned into the environment in the \code{data} slot.}

}

\section{Slots}{
    \describe{
        \item{\code{data}:}{An \code{environment} which contains at least one element named \code{"iData"}, which is a matrix-like object with rows equal to the number of features and columns equal to the number of non-missing pixels. Each column is a feature vector.}

        \item{\code{coord}:}{An \code{data.frame} with rows giving the spatial coordinates of the pixels corresponding to the columns of \code{"iData"}.}

        \item{\code{positionArray}:}{An \code{array} with dimensions equal to the spatial dimensions of the image, which stores the column numbers of the feature vectors corresponding to the pixels in the \code{"iData"} element of the \code{data} slot. This allows re-construction of the imaging "datacube" on-the-fly.}

        \item{\code{dim}:}{A length 2 integer vector analogous to the 'dim' attribute of an ordinary R matrix.}

        \item{\code{dimnames}:}{A length 2 \code{list} analogous to the 'dimnames' attribute of an ordinary R matrix.}
        
        \item{\code{storageMode}:}{A \code{character} which is one of \code{"immutableEnvironment"}, \code{"lockedEnvironment"}, or \code{"environment"}. The values \code{"lockedEnvironment"} and \code{"environment"} behave as described in the documentation of \code{\link{AssayData}}. An \code{"immutableEnvironment"} uses a locked environment while retaining R's typical copy-on-write behavior. Whenever an object in an immutable environment is modified, a new environment is created for the \code{data} slot, and all objects copied into it. This allows usual R functional semantics while avoiding copying of large objects when other slots are modified.}

        \item{\code{.__classVersion__}:}{A \code{Versions} object describing the version of the class used to created the instance. Intended for developer use.}
    }
}

\section{Extends}{
   \code{\linkS4class{Versioned}}
}

\section{Creating Objects}{
    \code{SImageData} instances are usually created through \code{SImageData()}.
}

\section{Methods}{
    Class-specific methods:
    \describe{
        \item{\code{iData(object)}, \code{iData(object)<-}:}{Return or set the matrix of image intensities. Columns should correspond to feature vectors, and rows should correspond to pixel vectors.}

        \item{\code{coord(object)}, \code{coord(object)<-}:}{Return or set the coodinates. This is a \code{data.frame} with each row corresponding to the spatial coordinates of a pixel.}

        \item{\code{positionArray(object)}, \code{positionArray(object)<-}:}{Return or set the \code{positionArray} slot. When setting, this should be an array returned by a call to \code{generatePositionArray}.}

        \item{\code{featureNames(object), featureNames(object) <- value}:}{Access and set feature names (names of the rows of the intensity matrix).}

        \item{\code{pixelNames(object), pixelNames(object) <- value}:}{Access and set the pixel names (names of the columns of the intensity matrix).}

        \item{\code{storageMode(object)}, \code{storageMode(object)<-}:}{Return or set the storage mode. See documentation on the \code{storageMode} slot above for more details.}
    }

    Standard generic methods:
    \describe{
        \item{\code{combine(x, y, ...)}:}{Combine two or more \code{SImageData} objects. Elements must be matrix-like objects and are combined column-wise with a call to 'cbind'. The numbers of rows must match, but otherwise no checking of row or column names is performed. The pixel coordinates are checked for uniqueness.}

        \item{\code{dim}:}{Return the dimensions of the (virtual) datacube. This is equal to the number of features (the number of rows in the matrix returned by \code{iData}) and the dimensions of the \code{positionArray} slot. For a standard imaging dataset, that is the number features followed by the spatial dimensions of the image.}

        \item{\code{dims}:}{A matrix where each column corresponds to the dimensions of the (virtual) datacubes stored as elements in the \code{data} slot. See above for how the dimensions are calculated.}

        \item{\code{SImageData[i, j, ..., drop]}:}{Access intensities in the (virtual) imaging datacube. The datacube is reconstructed on-the-fly. The object can be indexed like any ordinary array with number of dimensions equal to \code{dim(object)}. Use \code{drop = NULL} to return a subset of the same class as the object.}
    }
}

\author{Kylie A. Bemis}

\seealso{
    \code{\linkS4class{ImageData}},
    \code{\linkS4class{MSImageData}},
    \code{\linkS4class{SImageSet}},
    \code{\linkS4class{MSImageSet}}
}

\examples{
## Create an SImageData object
SImageData()

## Using a P x N matrix
data1 <- matrix(1:27, nrow=3)
coord <- expand.grid(x=1:3, y=1:3)
sdata1 <- SImageData(data1, coord)
sdata1[] # extract data as array

## Using a P x X x Y array
data2 <- array(1:27, dim=c(3,3,3))
sdata2 <- SImageData(data2)
sdata2[] # should be identical to above

# Missing data from some pixels
data3 <- matrix(1:9, nrow=3)
sdata3 <- SImageData(data3, coord[c(1,5,9),])

dim(sdata3) # presents as an array
iData(sdata3) # stored as matrix
sdata3[] # recontruct the datacube

iData(sdata3)[,1] <- 101:103 # assign using iData()
sdata3[] # can only assign into matrix representation

## Sparse feature vectors
data4 <- Hashmat(nrow=9, ncol=9)
sdata4 <- SImageData(data4, coord)
iData(sdata4)[] <- diag(9)
sdata4[1,,]
}

\keyword{classes}
