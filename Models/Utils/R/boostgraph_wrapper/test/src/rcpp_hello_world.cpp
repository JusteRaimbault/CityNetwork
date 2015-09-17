
// [[Rcpp::depends(BH)]]
#include <Rcpp.h>
#include <iostream>
//#include <boost/graph/boyer_myrvold_planar_test.hpp>
#include <boost/math/common_factor.hpp>
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
  return 0;
}

// [[Rcpp::export]]
/*int computeGCD(int a, int b) {
    return boost::math::gcd(a, b);
}
*/

// [[Rcpp::export]]
bool rcpp_boyer_myrvold_planar_test(){
  //construct the graph from the adjacency matrix
  // function matrix_as_graph

  return true;
  //return boyer_myrvold_planar_test(g);

}
