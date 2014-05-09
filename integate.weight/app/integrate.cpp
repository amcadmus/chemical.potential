#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <list>
#include <map>
#include <set>
#include <sstream>
#include <string>
#include <queue>
#include <vector>
#include <cmath>
#include <time.h>

#include "RandomGenerator.h"
#include "BlockAverage.h"
#include <boost/program_options.hpp>

namespace po = boost::program_options;

struct WX 
{
  double at;
  double hy;
  double cg;
  double rcut;
  double p0, p1, p2, p3, p4;
public:
  WX (const double & at,
      const double & hy,
      const double & rc);
  double value (const double & xx);
}
    ;

WX::WX (const double & at_,
	const double & hy_,
	const double & rc_)
{
  at = at_;
  hy = hy_;
  cg = rc_;
  rcut = rc_;
  p0 = cg;
  p1 = p0 + hy - rcut;
  p2 = p1 + rcut + at + rcut;
  p3 = p2 + hy - rcut;
  p4 = p3 + cg;
}

double
WX::value (const double & xx)
{
  if (xx < p0){
    return 0;
  }
  else if (xx < p1){
    return .5 - 0.5 * cos( (xx - p0) / (p1 - p0) * 1. *M_PI);
  }
  else if (xx < p2){
    return 1.;
  }
  else if (xx < p3){
    return .5 + 0.5 * cos( (xx - p2) / (p3 - p2) * 1. * M_PI);
  }
  else {
    return 0.;
  }
}

void
sphere (double & x, double & y, double & z)
{
  while (1){
    x = RandomGenerator_MT19937::genrand_real3() - 0.5;
    y = RandomGenerator_MT19937::genrand_real3() - 0.5;
    z = RandomGenerator_MT19937::genrand_real3() - 0.5;
    x *= 2.;
    y *= 2.;
    z *= 2.;
    double r = x*x + y*y + z*z;
    r = sqrt(r);
    if (r < 1.) {
      return;
    }
  }
}



int main (int argc, char * argv[])
{
  double at, hy, cutoff;
  int nsphere, nposi;
  
  po::options_description desc ("Allow options");  
  desc.add_options()
      ("help,h", "print this message")
      ("at", po::value<double > (&at)->default_value (1.6), "size of at region")
      ("hy", po::value<double > (&hy)->default_value (5.7), "size of cg region")
      ("n-sphere", po::value<int > (&nsphere)->default_value (100), "number of smapling for spherical integral")
      ("n-position", po::value<int > (&nposi)->default_value (100), "number of smapling for x-dir")
      ("cut-off", po::value<double > (&cutoff)->default_value (2.8), "cut-off");

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify (vm);

  if (vm.count("help") || vm.count("h")){
    std::cout << desc<< "\n";
    return 0;
  }

  WX mywx (at, hy, cutoff);

  // for (unsigned ii = 0; ii < 1e4; ++ii){
  //   double xx = ii * 0.01;
  //   double yy = mywx.value (xx);
  //   printf ("%f %f\n", xx, yy);
  // }

  BlockAverage_acc baposi (1);

  for (int ii = 0; ii < nposi; ++ii){
    if (ii % 100 == 0){
      printf ("# process: %.1f percent\r", double(double(ii) / double(nposi) * 100.0));
      fflush (stdout);
    }
    double posix = RandomGenerator_MT19937::genrand_real1();
    posix *= mywx.p4;
    double w1 = mywx.value (posix);
    if (w1 == 0){
      baposi.deposite (0.0);
      continue;
    }
    BlockAverage_acc basphere (1);
    for (int jj = 0; jj < nsphere; ++jj){
      double xx, yy, zz;
      sphere (xx, yy, zz);
      xx *= cutoff;
      yy *= cutoff;
      zz *= cutoff;
      double w2 = mywx.value (posix + xx);
      basphere.deposite (w1 * w2);
    }
    basphere.calculate();
    baposi.deposite (basphere.getAvg());
  }
  printf ("\n");

  baposi.calculate();

  printf ("%f %f\n", baposi.getAvg(), baposi.getAvgError());
  
  return 0;
}

  
