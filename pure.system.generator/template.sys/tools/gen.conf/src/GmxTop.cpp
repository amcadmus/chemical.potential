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

#include "GmxTop.h"
#include "StringSplit.h"

#define MAX_LINE_LENGTH 2048
#define MAX_NAME_LENGTH 32

using namespace GmxTop;

static inline void
die_wrong_format (const string & file,
		  const int & line)
{
  cerr << "wrong format error happing at file "
       << file << " : "
       << line << endl;
  exit (1);
}

static bool
ifKeyWord (const string & in,
	   string & key)
{
  if (!(in[0] == '[')){
    return false;
  }
  key.clear ();
  
  for (unsigned ii = 0; ii < in.size(); ++ii){
    if (in[ii] != '[' && in[ii] != ']' && in[ii] != ' '){
      key.push_back (in[ii]);
    }
  }
  return true;
}


static bool
notTrivalLine (const string & line)
{
  if (line.size() > 0 && line[0] != ';'){
    vector<string > words;
    StringOperation::split (line, words);
    if (words.size() > 0){
      return true;
    }
  }
  return false;
}

static void 
readBlocks (ifstream & file,
	    vector<string> & keys,
	    vector<vector<string > > & lines)
{
  bool inBlock = false;
  vector<string > blockLines;
  string tmpKey;
  char line[MAX_LINE_LENGTH];  
  
  while (! file.eof() ){
    file.getline (line, MAX_LINE_LENGTH);
    // cout << line <<endl;
    
    if (!inBlock){
      if (ifKeyWord(line, tmpKey)){
	inBlock = true;
	keys.push_back ("");
	keys.push_back (tmpKey);
	lines.push_back (blockLines);
	blockLines.clear ();
      }
      else if (notTrivalLine(line)) {
	blockLines.push_back(line);	
      }
    }
    else {
      if (ifKeyWord(line, tmpKey)){
	keys.push_back (tmpKey);
	lines.push_back (blockLines);
	blockLines.clear ();	
      }
      else if (notTrivalLine(line)){
	blockLines.push_back(line);
      }
    }
  }
  lines.push_back (blockLines);
}




// void
// realMol (ifstream & file,
// 	 gmx_mol & mol,
// 	 string & key)
// {
//   while (!file.eof()){
//     file.getline (line, MAX_LINE_LENGTH);
//     vector<string > words;
//     if (line.size() > 0 && line[0] != ';'){
//       StringOperation::split (line, words);
//       if (words.size() == 2){
// 	mol.name = words[0];
//       }
//     }    
//   }
// }

GmxTop::gmx_atom::
gmx_atom ()
    : charge (0.0), mass (0.0), cgnr(1)
{
}

void GmxTop::gmx_atom::
clear ()
{
  charge = 0.;
  mass = 0.;
  name = "";
  type = "";
  cgnr = 1;
}

// void
void GmxTop::
parseTop (const string & fname,
	  gmx_sys_top & top)
{
  ifstream file (fname.c_str());
  if (! file.is_open()){
    cerr << "cannot open file " << fname << endl;
    exit (1);
  }

  vector<string > keys;
  vector<vector<string > > lines;
  readBlocks (file, keys, lines);
  vector<string > words;

  // cout << "n. keys " << keys.size() << endl;
  // cout << "n. lines " << lines.size() << endl;
  // for (unsigned ii = 0; ii < keys.size(); ++ii){
  //   cout << "key: " << keys[ii] << endl;
  //   for (unsigned jj = 0; jj < lines[ii].size(); ++jj){
  //     cout << lines[ii][jj] << endl;
  //   }
  // }
  
  for (unsigned ii = 0; ii < keys.size(); ++ii){
    if (keys[ii] == "moleculetype"){
      gmx_mol tmpmol;
      StringOperation::split (lines[ii][0], words);
      tmpmol.name = words[0];
      unsigned jj = ii+1; 
      for (;jj < keys.size(); ++jj){
	if (keys[jj] == "moleculetype"){
	  break;
	}
      }
      for (unsigned kk = ii+1; kk < jj; ++kk){
	if (keys[kk] == "atoms"){
	  gmx_atom tmpatom;
	  for (unsigned ll = 0; ll < lines[kk].size(); ++ll){
	    tmpatom.clear ();
	    StringOperation::split (lines[kk][ll], words);
	    if (words.size() >= 2){
	      tmpatom.type = words[1];
	    }
	    if (words.size() >= 5){
	      tmpatom.name = words[4];
	    }
	    if (words.size() >= 6){
	      tmpatom.cgnr = atoi (words[5].c_str());
	    }
	    if (words.size() >= 7){
	      tmpatom.charge = atof (words[6].c_str());
	    }
	    if (words.size() >= 8){
	      tmpatom.mass = atof (words[7].c_str());
	    }
	    tmpmol.atoms.push_back (tmpatom);
	  }
	}
      }
      top.moles.push_back (tmpmol);
      ii = jj - 1;
    }
  }

  for (unsigned ii = 0; ii < keys.size(); ++ii){
    if (keys[ii] == "molecules"){
      if (lines[ii].size() != top.moles.size()){
	cerr << "num. mole does not match the num. of lines in sec. [ molecules ], stop." << endl;
	exit(1);
      }
      for (unsigned jj = 0; jj < lines[ii].size(); ++jj){
	StringOperation::split (lines[ii][jj], words);
	if (words.size () < 2) die_wrong_format (__FILE__, __LINE__);
	if (words[0] != top.moles[jj].name){
	  cerr << "mole " << top.moles[jj].name << " is not matched in the [ molecules ] section, stop." << endl;
	  exit(1);
	}
	top.numMol.push_back(atoi(words[1].c_str()));
      }
    }
  }   
}

