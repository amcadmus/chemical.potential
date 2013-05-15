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
#include "StringSplit.h"
#include "GmxTop.h"

namespace po = boost::program_options;
using namespace GmxTop;

int main (int argc, char * argv[])
{
  string ofilename;
  string tpfilename;
  vector<string> exName, cgName;
  string exNameString, cgNameString;
  po::options_description desc ("Allow options");
  
  desc.add_options()
      ("help,h", "print this message")
      ("ex-name", po::value<std::string > (&exNameString)->default_value (std::string("EX")), "name of explicit group")
      ("cg-name", po::value<std::string > (&cgNameString)->default_value (std::string("CG")), "name of explicit group")
      ("output,o", po::value<std::string > (&ofilename)->default_value (std::string("index.ndx")), "output index file")
      ("topol,p",  po::value<std::string > (&tpfilename)->default_value (std::string("topol.top")), "input topol name");

  po::variables_map vm;
  po::store(po::parse_command_line(argc, argv, desc), vm);
  po::notify (vm);

  if (vm.count("help") || vm.count("h")){
    std::cout << desc<< "\n";
    return 0;
  }
  
  StringOperation::split (exNameString, exName);
  StringOperation::split (cgNameString, cgName);

  gmx_sys_top top;
  parseTop (tpfilename, top);

  vector<vector<int > > exIdx, cgIdx;

  FILE * fp = fopen (ofilename.c_str(), "w");
  if (fp == NULL){
    cerr << "cannot open file " << ofilename << endl;
    return 1;
  }
  unsigned countAtom = 0;
  fprintf (fp, "[ System ]\n");
  for (unsigned ii = 0; ii < top.moles.size(); ++ii){
    for (unsigned jj = 0; jj < unsigned(top.numMol[ii]); ++jj){
      for (unsigned kk = 0; kk < top.moles[ii].atoms.size(); ++kk){
	fprintf (fp, "%d ", ++countAtom);
	if (countAtom % 15 == 0) {
	  fprintf (fp, "\n");
	}
      }
    }
  }
  fprintf (fp, "\n");
  
  // loop over moles
  countAtom = 0;
  unsigned countPrint = 0;
  for (unsigned ii = 0; ii < top.moles.size(); ++ii){
    vector<int > tmpExIdx, tmpCgIdx;
    fprintf (fp, "[ %s ]\n", top.moles[ii].name.c_str());
    countPrint = 0;
    for (unsigned jj = 0; jj < unsigned(top.numMol[ii]); ++jj){
      for (unsigned kk = 0; kk < top.moles[ii].atoms.size(); ++kk){
	countAtom ++;
	if (kk ==  top.moles[ii].atoms.size() -1 ){
	  tmpCgIdx.push_back (countAtom);
	}
	else {
	  tmpExIdx.push_back (countAtom);
	}
	fprintf (fp, "%d ", countAtom);
	if (++countPrint % 15 == 0) {
	  fprintf (fp, "\n");
	}
      }
    }
    fprintf (fp, "\n");
    exIdx.push_back (tmpExIdx);
    cgIdx.push_back (tmpCgIdx);
  }

  for (unsigned jj = 0; jj < exIdx.size(); ++jj){
    if (ii >= exName.size()) {
      cerr << "inconsistent number of mole name in top and number of ex name on command line" << endl;
      cerr << "ex names are: " << exNameString << endl;
      return 1;
    }
    if (ii >= cgName.size()) {
      cerr << "inconsistent number of mole name in top and number of cg name on command line" << endl;
      cerr << "cg names are: " << cgNameString << endl;
      return 1;
    }
    fprintf (fp, "[ %s ]\n", exName[jj].c_str());
    for (unsigned ii = 0; ii < exIdx[jj].size(); ++ii){
      fprintf (fp, "%d ", exIdx[jj][ii]);
      if ((ii+1) % 15 == 0) {
	fprintf (fp, "\n");
      }
    }
    fprintf (fp, "\n");
    fprintf (fp, "[ %s ]\n", cgName[jj].c_str());
    for (unsigned ii = 0; ii < cgIdx[jj].size(); ++ii){
      fprintf (fp, "%d ", cgIdx[jj][ii]);
      if ((ii+1) % 15 == 0) {
	fprintf (fp, "\n");
      }
    }
    fprintf (fp, "\n");
  }
  
  return 0;
}

  
