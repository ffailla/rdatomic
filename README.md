# rdatomic

This is still a work in progress. I would like to package this up as a proper R package.

This library provides a bridge between R and Datomic. It uses the rJava library to make calls into the Datomic Java API. The goal is to make is calls to Datomic return data structures that are consubmable by idomatic R functions.

# Usage
I have not yet hooked this library into the R packaging framework. To wuse and work with this library, you would first run the deps.sh script, which will download the required Java dependencies into the ./lib folder.

The test.R file contains some example interop calls

## License

Licensed under the EPL. (See the file epl.html.)
