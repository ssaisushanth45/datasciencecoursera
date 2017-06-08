## The functions first creates a special matrix object to the cache memory
## and then retrieves the object from the cache instead re-running. 
## The first function computes the inverse of a matrix and stores it in cache.
## (in an environment different than the current environment). The second
## function computes the inverse of the matrix (special object) and returns it
## from the cache. If the inverse was already computed
## and the matrix is unchanged, it will simply retrieve the object from cache. 

## Creates a special object that can cache its inverse

makeCacheMatrix <- function(x = matrix()) {

    m <- NULL
    set <- function(y) {
        x <<- y
        m <<- NULL
    }
    get <- function() x
    setinv <- function(solve) m <<- solve
    getinv <- function() m
    list(set = set, get = get,
         setinv = setinv,
         getinv = getinv)
}


## Computes the inverse of the matrix returned by the above function

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
    m <- x$getinv()
    if(!is.null(m)) {
        message("getting cached data")
        return(m)
    }
    data <- x$get()
    m <- solve(data, ...)
    x$setinv(m)
    m
}
