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

namespace po = boost::program_options;

int main (int argc, char * argv[])
{
  std::string ifilename;
  std::string ofilename;
  po::options_description desc ("Allow options");  
  double rch4 = 0;
  unsigned nch4;
  
  desc.add_options()
      ("help,h", "print this message")
      ("ch4-num,n",     po::value<unsigned >	(&nch4)->default_value (0),   "number of ch4 in water, overwrites the ratio")
      ("ch4-ratio,r",   po::value<double >	(&rch4)->default_value (0.0), "ratio of ch4 in water")
      ("output-file,o", po::value<std::string > (&ofilename)->default_value (std::string("out.gro"), "output conf file name"))
      ("input-file,f",  po::value<std::string > (&ifilename)->default_value (std::string("conf.gro"), "input conf file name"));

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

  std::vector<int >  resdindex1;
  std::vector<std::string >   resdname1;
  std::vector<std::string >   atomname1;
  std::vector<int >  atomindex1;
  std::vector<std::vector<double > >  posi1;
  std::vector<std::vector<double > >  velo1;

  unsigned nmol = posi.size() / 4;
  if (nch4 == 0) {
    nch4 = rch4 * nmol;
  }
  unsigned nwat = nmol - nch4;

  std::cout << "# ch4 ratio is " << rch4 << std::endl;
  std::cout << "# nmol is " << nmol << std::endl;
  std::cout << "# nmol ch4   is " << nch4 << std::endl;
  std::cout << "# nmol water is " << nwat << std::endl;
  std::cout << "# actual ch4 ratio is " << double(nch4) / double(nmol) << std::endl;
  std::cout << "# size is " << atomname.size() << std::endl;
  
  resdindex1.resize(nwat * 4 + nch4 * 2);
  atomindex1.resize(nwat * 4 + nch4 * 2);
  resdname1.resize(nwat * 4 + nch4 * 2);
  atomname1.resize(nwat * 4 + nch4 * 2);
  posi1.resize(nwat * 4 + nch4 * 2);
  velo1.resize(nwat * 4 + nch4 * 2);

  for (unsigned i = 0; i < nwat * 4; ++i){
    resdindex1[i] = resdindex[i];
    atomindex1[i] = atomindex[i];
    resdname1[i] = resdname[i];
    atomname1[i] = atomname[i];
    posi1[i] = posi[i];
    velo1[i] = velo[i];
  }

  for (unsigned i = 0; i < nch4; ++i){
    resdindex1[nwat * 4 + i * 2 + 0] = resdindex[nwat * 4 - 1] + i * 2 + 1;
    atomindex1[nwat * 4 + i * 2 + 0] = atomindex[nwat * 4 - 1] + i * 2 + 1;
    resdname1[nwat * 4 + i * 2 + 0] = "Meth";
    atomname1[nwat * 4 + i * 2 + 0] = "CH4";
    resdindex1[nwat * 4 + i * 2 + 1] = resdindex[nwat * 4 - 1] + i * 2 + 2;
    atomindex1[nwat * 4 + i * 2 + 1] = atomindex[nwat * 4 - 1] + i * 2 + 2;
    resdname1[nwat * 4 + i * 2 + 1] = "Meth";
    atomname1[nwat * 4 + i * 2 + 1] = "CMC";
    
    posi1[nwat * 4 + i * 2 + 0] = posi[nwat * 4 + i * 4];
    velo1[nwat * 4 + i * 2 + 0] = velo[nwat * 4 + i * 4];
    posi1[nwat * 4 + i * 2 + 1] = posi[nwat * 4 + i * 4];
    velo1[nwat * 4 + i * 2 + 1] = velo[nwat * 4 + i * 4];
  }
  
  GroFileManager::write (ofilename,
			 resdindex1, resdname1,
			 atomname1, atomindex1,
			 posi1, velo1, boxsize);
  // FILE * fp = fopen ("topol.top", "w");
  // fprintf (fp, "#include \"system.itp\"\n[ molecules ]\nSOL %d\nTWALLA %d\nTWALLB %d\n",
  // 	   natom/3, naddHalf, naddHalf);
  // fclose (fp);
  
  return 0;
}

  
