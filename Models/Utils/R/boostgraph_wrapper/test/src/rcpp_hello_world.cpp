
#include <Rcpp.h>
#include <iostream>
using namespace Rcpp;

// [[Rcpp::export]]
List rcpp_hello_world() {

    CharacterVector x = CharacterVector::create( "foo", "bar" )  ;
    NumericVector y   = NumericVector::create( 0.0, 1.0 ) ;
    List z            = List::create( x, y ) ;

    return z ;
}

// [[Rcpp::export]]
int testvoid(){
  int i = 0;
  while (i<100) {
    std::cout << i ;i++;
  }
}
