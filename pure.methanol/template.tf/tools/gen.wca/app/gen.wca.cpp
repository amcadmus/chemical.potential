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

#include <boost/program_options.hpp>

namespace po = boost::program_options;
using namespace std;

#define MaxLineLength 10240

int main(int argc, char * argv[])
{
  double xup;
  double bin;
  double ucap;
  double eps;
  double sig;
  string ofile;
  
  po::options_description desc ("Allow options");
  desc.add_options()
    ("help,h", "print this message")
    ("epsilon,e", po::value<double > (&eps)->default_value (0.650194),  "epsilon")
    ("sigma,s",   po::value<double > (&sig)->default_value (0.316557),  "epsilon")
    ("bin,b", po::value<double > (&bin)->default_value (0.002), "size of the bin")
    ("xup,x", po::value<double > (&xup)->default_value (2.0), "up of x")
    ("ucap,u", po::value<double > (&ucap)->default_value (1e6), "cap value of energy")
    ("output,o",   po::value<std::string > (&ofile)->default_value ("table_CG_CG.xvg"), "output file");
  
  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify (vm);
  if (vm.count("help")){
    std::cout << desc<< "\n";
    return 0;
  }

  int nx = int((xup + 0.5 * bin) / bin) + 1;
  
  FILE *fp = fopen (ofile.c_str(), "w");
  if (fp == NULL){
    std::cerr << "cannot open file " << ofile << std::endl;
    exit (1);
  }

  double rcut = pow (2., 1./6.) * sig;

  fprintf (fp, "# gen with eps: %f, sigma: %f\n",
	   eps, sig);
  // fprintf (fp, "%e   %e %e   %e %e   %e %e\n",
  // 	   0., 0., 0., 0., 0., ucap, 0.);
  double fcap;
  double rcap;
  for (int ii = 0; ii < nx; ++ii){
    double tmpx = ii * bin;
    rcap = tmpx;
    double tmpr6 = sig / tmpx;
    tmpr6 = tmpr6 * tmpr6 * tmpr6 * tmpr6 * tmpr6 * tmpr6;
    double tmpu = 4. * eps * (tmpr6 * tmpr6 - tmpr6) + eps;
    fcap = 4 * eps * (tmpr6 * tmpr6 * 12. / tmpx - 6. * tmpr6 / tmpx);
    if (tmpu <= ucap) break;
  }

  for (int ii = 0; ii < nx; ++ii){
    double tmpx = ii * bin;
    // if (ii == 0){
    //   tmpx = 0.5 * ii * bin;
    // }
    double tmpr6 = sig / tmpx;
    tmpr6 = tmpr6 * tmpr6 * tmpr6 * tmpr6 * tmpr6 * tmpr6;
    double tmpu = 4. * eps * (tmpr6 * tmpr6 - tmpr6) + eps;
    double tmpf = 0.;
    if (tmpu > ucap || ii == 0){
      tmpu = ucap + fcap * (rcap - tmpx);
      tmpf = fcap;
    }
    else {
      tmpf = 4 * eps * (tmpr6 * tmpr6 * 12. / tmpx - 6. * tmpr6 / tmpx);
    }
    if (tmpx >= rcut){
      tmpu = 0.;
      tmpf = 0.;
    }
    fprintf (fp, "%e   %e %e   %e %e   %e %e\n",
	     tmpx, 0., 0., 0., 0., tmpu, tmpf);
  }
  
  
  fclose (fp);
  
  return 0;
}

