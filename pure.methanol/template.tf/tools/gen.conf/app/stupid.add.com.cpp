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

  
  desc.add_options()
      ("help,h", "print this message")
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

  unsigned nmol = resdindex.back();
  unsigned nwat, nMeOH;
  for (nwat = 0; ; nwat ++){
    if (nwat == resdname.size() || resdname[nwat] != std::string ("SOL")) {
      break;
    }
  }
  nwat = nwat / 3;
  nMeOH = nmol - nwat;
  
  std::cout << "# nmol is " << nmol << std::endl;
  std::cout << "# nmol MeOH   is " << nMeOH << std::endl;
  std::cout << "# nmol water is " << nwat << std::endl;
  
  resdindex1.resize(nwat * 4 + nMeOH * 4);
  atomindex1.resize(nwat * 4 + nMeOH * 4);
  resdname1.resize (nwat * 4 + nMeOH * 4);
  atomname1.resize (nwat * 4 + nMeOH * 4);
  posi1.resize     (nwat * 4 + nMeOH * 4);
  velo1.resize     (nwat * 4 + nMeOH * 4);
  
  unsigned countAtom = 0;
  std::vector<double > mass (3, 1.00800);
  mass[0] = 15.99940;
  double totalmass = mass[0] + mass[1] + mass[2];

  std::cout << "size is " << atomname.size() << std::endl;
  
  for (unsigned i = 0; i < nwat; ++i){
    resdindex1[4*i+0] = resdindex[3*i+0];
    resdindex1[4*i+1] = resdindex[3*i+0];
    resdindex1[4*i+2] = resdindex[3*i+0];
    resdindex1[4*i+3] = resdindex[3*i+0];
    atomindex1[4*i+0] = ++ countAtom;
    atomindex1[4*i+1] = ++ countAtom;
    atomindex1[4*i+2] = ++ countAtom;
    atomindex1[4*i+3] = ++ countAtom;
    resdname1[4*i+0] = resdname[3*i+0];
    resdname1[4*i+1] = resdname[3*i+0];
    resdname1[4*i+2] = resdname[3*i+0];
    resdname1[4*i+3] = resdname[3*i+0];
    atomname1[4*i+0] = atomname[3*i+0];
    atomname1[4*i+1] = atomname[3*i+1];
    atomname1[4*i+2] = atomname[3*i+2];
    atomname1[4*i+3] = "CMW";

    std::vector<double > composi(3, 0.);
    std::vector<double > comvelo(3, 0.);
    
    for (unsigned jj = 0; jj < 3; ++jj){
      for (unsigned dd = 0; dd < 3; ++dd){
	composi[dd] += mass[jj] * posi[3*i+jj][dd];
	comvelo[dd] += mass[jj] * velo[3*i+jj][dd];
      }
    }
    for (unsigned dd = 0; dd < 3; ++dd){
      composi[dd] /= totalmass;
      comvelo[dd] /= totalmass;
    }
    posi1[4*i+0] = posi[3*i+0];
    posi1[4*i+1] = posi[3*i+1];
    posi1[4*i+2] = posi[3*i+2];
    posi1[4*i+3] = composi;
    velo1[4*i+0] = velo[3*i+0];
    velo1[4*i+1] = velo[3*i+1];
    velo1[4*i+2] = velo[3*i+2];
    velo1[4*i+3] = comvelo;
  }  

  mass[0] = 15.035;
  mass[1] = 15.999;
  mass[2] =  1.008;
  totalmass = mass[0] + mass[1] + mass[2];
  unsigned shift1 = 4 * nwat;
  unsigned shift = 3 * nwat;

  for (unsigned i = 0; i < nMeOH; ++i){
    resdindex1[shift1 +4*i+0] = resdindex[shift +3*i+0];
    resdindex1[shift1 +4*i+1] = resdindex[shift +3*i+0];
    resdindex1[shift1 +4*i+2] = resdindex[shift +3*i+0];
    resdindex1[shift1 +4*i+3] = resdindex[shift +3*i+0];
    atomindex1[shift1 +4*i+0] = ++ countAtom;
    atomindex1[shift1 +4*i+1] = ++ countAtom;
    atomindex1[shift1 +4*i+2] = ++ countAtom;
    atomindex1[shift1 +4*i+3] = ++ countAtom;
    resdname1[shift1 +4*i+0] = resdname[shift +3*i+0];
    resdname1[shift1 +4*i+1] = resdname[shift +3*i+0];
    resdname1[shift1 +4*i+2] = resdname[shift +3*i+0];
    resdname1[shift1 +4*i+3] = resdname[shift +3*i+0];
    atomname1[shift1 +4*i+0] = atomname[shift +3*i+0];
    atomname1[shift1 +4*i+1] = atomname[shift +3*i+1];
    atomname1[shift1 +4*i+2] = atomname[shift +3*i+2];
    atomname1[shift1 +4*i+3] = "CMC";

    std::vector<double > composi(3, 0.);
    std::vector<double > comvelo(3, 0.);
    
    for (unsigned jj = 0; jj < 3; ++jj){
      for (unsigned dd = 0; dd < 3; ++dd){
	composi[dd] += mass[jj] * posi[shift +3*i+jj][dd];
	comvelo[dd] += mass[jj] * velo[shift +3*i+jj][dd];
      }
    }
    for (unsigned dd = 0; dd < 3; ++dd){
      composi[dd] /= totalmass;
      comvelo[dd] /= totalmass;
    }
    posi1[shift1 +4*i+0] = posi[shift +3*i+0];
    posi1[shift1 +4*i+1] = posi[shift +3*i+1];
    posi1[shift1 +4*i+2] = posi[shift +3*i+2];
    posi1[shift1 +4*i+3] = composi;
    velo1[shift1 +4*i+0] = velo[shift +3*i+0];
    velo1[shift1 +4*i+1] = velo[shift +3*i+1];
    velo1[shift1 +4*i+2] = velo[shift +3*i+2];
    velo1[shift1 +4*i+3] = comvelo;
  }  

  // for (unsigned ii = 0; ii < nMeOH; ++ii){
  //   resdindex1[4*nwat + 2*ii + 0] = resdindex[3*nwat + ii];
  //   resdindex1[4*nwat + 2*ii + 1] = resdindex[3*nwat + ii];
  //   atomindex1[4*nwat + 2*ii + 0] = ++ countAtom;
  //   atomindex1[4*nwat + 2*ii + 1] = ++ countAtom;
  //   resdname1[4*nwat + 2*ii + 0] = resdname[3*nwat + ii];
  //   resdname1[4*nwat + 2*ii + 1] = resdname[3*nwat + ii];
  //   atomname1[4*nwat + 2*ii + 0] = atomname[3*nwat + ii];
  //   atomname1[4*nwat + 2*ii + 1] = "CMC";

  //   posi1[4*nwat + 2*ii + 0] = posi[3*nwat + ii];
  //   posi1[4*nwat + 2*ii + 1] = posi[3*nwat + ii];
  //   velo1[4*nwat + 2*ii + 0] = velo[3*nwat + ii];
  //   velo1[4*nwat + 2*ii + 1] = velo[3*nwat + ii];
  // }
  
  
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

  
