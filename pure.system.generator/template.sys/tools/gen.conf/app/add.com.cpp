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
  string cgName;
  po::options_description desc ("Allow options");
  
  desc.add_options()
      ("help,h", "print this message")
      ("output,o", po::value<std::string > (&ofilename)->default_value (std::string("out.gro")), "output conf file name")
      ("topol,p",  po::value<std::string > (&tpfilename)->default_value (std::string("topol.top")), "input topol name")
      ("cg-name", po::value<std::string > (&cgName)->default_value (std::string("CG")), "name of explicit group")
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
  unsigned resdcount = 1;
  unsigned atomcount = 1;
  for (unsigned ii = 0; ii < top.moles.size(); ++ii){
    for (unsigned jj = 0; jj < unsigned(top.numMol[ii]); ++jj){
      std::vector<double > com (3, 0);
      std::vector<double > comvelo (3, 0);
      double totalMass = 0.;
      for (unsigned kk = 0; kk < top.moles[ii].atoms.size(); ++kk){
	for (unsigned dd = 0; dd < 3; ++dd){
	  com[dd] += posi[point][dd] * top.moles[ii].atoms[kk].mass;
	  comvelo[dd] += velo[point][dd] * top.moles[ii].atoms[kk].mass;
	}
	totalMass += top.moles[ii].atoms[kk].mass;
	posi1.push_back (posi[point]);
	velo1.push_back (velo[point]);
	resdname1.push_back (resdname[point]);
	atomname1.push_back (atomname[point]);
	resdindex1.push_back (resdcount);
	atomindex1.push_back (atomcount);
	point++;
	atomcount++;
      }
      for (unsigned dd = 0; dd < 3; ++dd){
	com[dd] /= totalMass;
	comvelo[dd] /= totalMass;
      }
      posi1.push_back (com);
      velo1.push_back (comvelo);
      resdname1.push_back (top.moles[ii].name);
      atomname1.push_back (cgName);
      resdindex1.push_back (resdcount);
      atomindex1.push_back (atomcount);
      resdcount ++;
      atomcount ++;
    }
  }
  
  GroFileManager::write (ofilename,
  			 resdindex1, resdname1,
  			 atomname1, atomindex1,
  			 posi1, velo1, boxsize);
  
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
