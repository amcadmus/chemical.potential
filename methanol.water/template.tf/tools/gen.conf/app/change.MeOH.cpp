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
  double rMeOH = 0;
  unsigned nMeOH;
  
  desc.add_options()
      ("help,h", "print this message")
      ("MeOH-num,n",     po::value<unsigned >	(&nMeOH)->default_value (0),   "number of MeOH in water, overwrites the ratio")
      ("MeOH-ratio,r",   po::value<double >	(&rMeOH)->default_value (0.0), "ratio of MeOH in water")
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

  unsigned nmol = posi.size() / 3;
  if (nMeOH == 0) {
    nMeOH = rMeOH * nmol;
  }
  unsigned nwat = nmol - nMeOH;

  std::cout << "# MeOH ratio is " << rMeOH << std::endl;
  std::cout << "# nmol is " << nmol << std::endl;
  std::cout << "# nmol MeOH   is " << nMeOH << std::endl;
  std::cout << "# nmol water is " << nwat << std::endl;
  std::cout << "# actual MeOH ratio is " << double(nMeOH) / double(nmol) << std::endl;
  std::cout << "# size is " << atomname.size() << std::endl;
  
  resdindex1.resize(nwat * 3 + nMeOH * 3);
  atomindex1.resize(nwat * 3 + nMeOH * 3);
  resdname1.resize(nwat * 3 + nMeOH * 3);
  atomname1.resize(nwat * 3 + nMeOH * 3);
  posi1.resize(nwat * 3 + nMeOH * 3);
  velo1.resize(nwat * 3 + nMeOH * 3);

  for (unsigned i = 0; i < nwat; ++i){
    resdindex1[3*i+0] = resdindex[3*i+0];
    resdindex1[3*i+1] = resdindex[3*i+1];
    resdindex1[3*i+2] = resdindex[3*i+2];
    atomindex1[3*i+0] = atomindex[3*i+0];
    atomindex1[3*i+1] = atomindex[3*i+1];
    atomindex1[3*i+2] = atomindex[3*i+2];
    resdname1[3*i+0] = "SOL";
    resdname1[3*i+1] = "SOL";
    resdname1[3*i+2] = "SOL";
    atomname1[3*i+0] = "OW";
    atomname1[3*i+1] = "HW1";
    atomname1[3*i+2] = "HW2";
    posi1[3*i+0] = posi[3*i+1];
    posi1[3*i+1] = posi[3*i+0];
    posi1[3*i+2] = posi[3*i+2];
    velo1[3*i+0] = velo[3*i+1];
    velo1[3*i+1] = velo[3*i+0];
    velo1[3*i+2] = velo[3*i+2];
  }

  for (unsigned i = 3 * nwat; i < 3 * nwat + nMeOH * 3; ++i){
    resdindex1[i] = resdindex[i];
    atomindex1[i] = atomindex[i];
    resdname1[i] = resdname[i];
    atomname1[i] = atomname[i];
    posi1[i] = posi[i];
    velo1[i] = velo[i];
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

  
