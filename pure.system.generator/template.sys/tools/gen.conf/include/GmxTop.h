#ifndef __GmxTop_h_wanghan__
#define __GmxTop_h_wanghan__

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <cmath>

using namespace std;

namespace GmxTop {
  struct gmx_atom
  {
    double	charge;
    double	mass;
    string	name;
    string	type;
    int		cgnr;
    gmx_atom ();
    void clear ();
  }
      ;

  struct gmx_mol
  {
    string		name;
    vector<gmx_atom>	atoms;
  }
      ;

  struct gmx_sys_top
  {
    vector<gmx_mol>	moles;
    vector<int>		numMol;
  }
      ;

  void parseTop (const string & fname,
		 gmx_sys_top & top);
};

#endif
