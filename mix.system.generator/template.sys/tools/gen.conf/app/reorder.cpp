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

using namespace std;

struct MoleBlock 
{
  int startIdx;
  int endIdx;
  string name;
  bool used;
}
    ;


int main (int argc, char * argv[])
{
  string ifilename;
  string ofilename;
  po::options_description desc ("Allow options");
  
  desc.add_options()
      ("help,h", "print this message")
      ("input,f", po::value<string > (&ifilename)->default_value (string("conf.gro")), "input gro file")
      ("output,o", po::value<string > (&ofilename)->default_value (string("out.gro")), "output gro file");

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify (vm);

  if (vm.count("help") || vm.count("h")){
    cout << desc<< "\n";
    return 0;
  }

  vector<int >  resdindex;
  vector<string >   resdname;
  vector<string >   atomname;
  vector<int >  atomindex;
  vector<vector<double > >  posi;
  vector<vector<double > >  velo;
  vector<double >  boxsize;
  vector<int >  resdindex1;
  vector<string >   resdname1;
  vector<string >   atomname1;
  vector<int >  atomindex1;
  vector<vector<double > >  posi1;
  vector<vector<double > >  velo1;
  
  GroFileManager::read (ifilename, resdindex, resdname, atomname, atomindex,
  			posi, velo, boxsize);

  unsigned pt = 0;
  string pname = resdname[0];
  vector<MoleBlock > blocks;
  
  for (unsigned pt1 = 1; pt1 < resdname.size(); ++pt1){
    if (pname != resdname[pt1]){
      printf ("%s %d\n", pname.c_str(), resdindex[pt1] - resdindex[pt]);
      MoleBlock tmp;
      tmp.startIdx = pt;
      tmp.endIdx = pt1;
      tmp.name = pname;
      tmp.used = false;
      blocks.push_back (tmp);
      pname = resdname[pt1];
      pt = pt1;
    }
    // cout << pt1 << endl;
  }
  printf ("%s %d\n", pname.c_str(), resdindex.back() - resdindex[pt] + 1);
  {
    MoleBlock tmp;
    tmp.startIdx = pt;
    tmp.endIdx = resdindex.size();
    tmp.name = pname;
    tmp.used = false;
    blocks.push_back (tmp);
  }

  for (unsigned ii = 0; ii < blocks.size(); ++ii){
    if (! blocks[ii].used ){
      for (unsigned jj = blocks[ii].startIdx; jj < unsigned(blocks[ii].endIdx); ++jj){
	resdindex1.push_back (resdindex[jj]);
	atomindex1.push_back (atomindex[jj]);
	resdname1.push_back (resdname[jj]);
	atomname1.push_back (atomname[jj]);
	posi1.push_back (posi[jj]);
	velo1.push_back (velo[jj]);
	blocks[ii].used = true;
      }
      for (unsigned kk = ii+1; kk < blocks.size(); ++kk){
	if (! blocks[kk].used && blocks[kk].name == blocks[ii].name){
	  for (unsigned jj = blocks[kk].startIdx; jj < unsigned(blocks[kk].endIdx); ++jj){
	    resdindex1.push_back (resdindex[jj]);
	    atomindex1.push_back (atomindex[jj]);
	    resdname1.push_back (resdname[jj]);
	    atomname1.push_back (atomname[jj]);
	    posi1.push_back (posi[jj]);
	    velo1.push_back (velo[jj]);
	    blocks[kk].used = true;
	  }
	}
      }
    }
  }

  // re index all resd and atoms
  {
    unsigned count = 1;
    pt = 0;
    unsigned ii;
    for (ii = 0; ii < resdindex1.size(); ++ii){
      if (resdindex1[ii] != resdindex1[pt]){
	for (unsigned jj = pt; jj < ii; ++jj){
	  resdindex1[jj] = count;
	}
	count ++;
	pt = ii;
      }
      atomindex1[ii] = ii+1;
    }
    for (unsigned jj = pt; jj < ii; ++jj){
      resdindex1[jj] = count;
    }
    count ++;
    pt = ii;
  }
  
  GroFileManager::write (ofilename, resdindex1, resdname1, atomname1, atomindex1,
			 posi1, velo1, boxsize);
  
  return 0;
}
