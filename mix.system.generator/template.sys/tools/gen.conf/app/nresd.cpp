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

#include "GroFileManager.h"
#include <boost/program_options.hpp>
#include "GmxTop.h"

namespace po = boost::program_options;
using namespace GmxTop;

int main (int argc, char * argv[])
{
  string ifilename;
  po::options_description desc ("Allow options");
  
  desc.add_options()
      ("help,h", "print this message")
      ("input,f", po::value<std::string > (&ifilename)->default_value (std::string("conf.gro")), "input gro file");

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify (vm);

  if (vm.count("help") || vm.count("h")){
    std::cout << desc<< "\n";
    return 0;
  }

  std::vector<int >  resdindex;
  std::vector<std::string >   resdname;
  std::vector<std::string >   atomname;
  std::vector<int >  atomindex;
  std::vector<std::vector<double > >  posi;
  std::vector<std::vector<double > >  velo;
  std::vector<double >  boxsize;
  
  GroFileManager::read (ifilename, resdindex, resdname, atomname, atomindex,
  			posi, velo, boxsize);

  unsigned pt = 0;
  string pname = resdname[0];
  
  for (unsigned pt1 = 1; pt1 < resdname.size(); ++pt1){
    if (pname != resdname[pt1]){
      printf ("%s %d\n", pname.c_str(), resdindex[pt1] - resdindex[pt]);
      pname = resdname[pt1];
      pt = pt1;
    }
    // cout << pt1 << endl;
  }
  printf ("%s %d\n", pname.c_str(), resdindex.back() - resdindex[pt] + 1);
  
  return 0;
}
