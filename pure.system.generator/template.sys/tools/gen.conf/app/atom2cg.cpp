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
  std::string ifilename;
  std::string ofilename;
  string tpfilename;
  po::options_description desc ("Allow options");
  
  desc.add_options()
      ("help,h", "print this message")
      ("output,o", po::value<std::string > (&ofilename)->default_value (std::string("out.gro")), "output conf file name")
      ("topol,p",  po::value<std::string > (&tpfilename)->default_value (std::string("topol.top")), "input topol name")
      ("input,f",  po::value<std::string > (&ifilename)->default_value (std::string("conf.gro")), "input conf file name");

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
  gmx_sys_top top;
  parseTop (tpfilename, top);

  std::vector<int >  resdindex1;
  std::vector<std::string >   resdname1;
  std::vector<std::string >   atomname1;
  std::vector<int >  atomindex1;
  std::vector<std::vector<double > >  posi1;
  std::vector<std::vector<double > >  velo1;

  // loop over moles
  unsigned point = 0;
  unsigned countMol = 0;
  for (unsigned ii = 0; ii < top.moles.size(); ++ii){
    for (unsigned jj = 0; jj < unsigned(top.numMol[ii]); ++jj){
      countMol ++;
      std::vector<double > com (3, 0);
      double totalMass = 0.;
      for (unsigned kk = 0; kk < top.moles[ii].atoms.size(); ++kk){
	for (unsigned dd = 0; dd < 3; ++dd){
	  com[dd] += posi[point][dd] * top.moles[ii].atoms[kk].mass;
	}
	totalMass += top.moles[ii].atoms[kk].mass;
	point++;
      }
      for (unsigned dd = 0; dd < 3; ++dd){
	com[dd] /= totalMass;
      }
      posi1.push_back (com);
      velo1.push_back (vector<double >(3, 0.));
      resdname1.push_back ("RESDN");
      atomname1.push_back ("ATOMN");
      resdindex1.push_back (countMol);
      atomindex1.push_back (countMol);      
    }
  }

  // unsigned nmol = posi.size() / 3;
  // resdindex1.resize(nmol);
  // atomindex1.resize(nmol);
  // resdname1.resize(nmol);
  // atomname1.resize(nmol);
  // posi1.resize(nmol);
  // velo1.resize(nmol);
  
  // // unsigned countAtom = 0;
  // std::vector<double > mass (3, 1.00800);
  // mass[0] = 15.99940;
  // double totalmass = mass[0] + mass[1] + mass[2];

  // std::cout << "nmol is " << nmol << std::endl;
  // std::cout << "size is " << atomname.size() << std::endl;
  
  // for (unsigned i = 0; i < nmol; ++i){
  //   resdindex1[i] = i;
  //   atomindex1[i] = i;
  //   resdname1[i] = "SOL";
  //   atomname1[i] = "CG";

  //   std::vector<double > composi(3, 0.);
  //   std::vector<double > comvelo(3, 0.);
    
  //   for (unsigned jj = 0; jj < 3; ++jj){
  //     for (unsigned dd = 0; dd < 3; ++dd){
  // 	composi[dd] += mass[jj] * posi[3*i+jj][dd];
  // 	comvelo[dd] += mass[jj] * velo[3*i+jj][dd];
  //     }
  //   }
  //   for (unsigned dd = 0; dd < 3; ++dd){
  //     composi[dd] /= totalmass;
  //     comvelo[dd] /= totalmass;
  //   }
  //   posi1[i] = composi;
  //   velo1[i] = comvelo;
  // }  
  
  
  GroFileManager::write (ofilename,
  			 resdindex1, resdname1,
  			 atomname1, atomindex1,
  			 posi1, velo1, boxsize);
  // // FILE * fp = fopen ("topol.top", "w");
  // // fprintf (fp, "#include \"system.itp\"\n[ molecules ]\nSOL %d\nTWALLA %d\nTWALLB %d\n",
  // // 	   natom/3, naddHalf, naddHalf);
  // // fclose (fp);

  // ifstream file (ifilename.c_str());
  // if (! file.is_open()){
  //   cerr << "cannot open file " << ifilename << endl;
  //   exit (1);
  // }

  // vector<string> keys;
  // vector<vector<string > > lines;
  
  // GmxTop::readBlocks (file, keys, lines);
  // cout << "n. keys " << keys.size() << endl;
  // cout << "n. lines " << lines.size() << endl;
  // for (unsigned ii = 0; ii < keys.size(); ++ii){
  //   cout << "key: " << keys[ii] << endl;
  //   for (unsigned jj = 0; jj < lines[ii].size(); ++jj){
  //     cout << lines[ii][jj] << endl;
  //   }
  // }

  
  // for (unsigned ii = 0; ii < top.moles.size(); ++ii){
  //   cout << "molname: " << top.moles[ii].name
  // 	 << " num: " << top.numMol[ii]
  // 	 << endl;
  //   for (unsigned jj = 0; jj < top.moles[ii].atoms.size(); ++jj){
  //     cout << "atom: " << top.moles[ii].atoms[jj].name << "   "
  // 	   << "mass: " << top.moles[ii].atoms[jj].mass
  // 	   << endl;
  //   }
  //   cout << endl;
  // }
  
  return 0;
}

  
