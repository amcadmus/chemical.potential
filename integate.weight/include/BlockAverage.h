#ifndef __BlockAverage_h_wanghan__
#define __BlockAverage_h_wanghan__

#include <vector>

class BlockAverage 
{
  double avg;
  double var;
  double error_avg;
  double error_var;
  unsigned nBlock;
  unsigned nDataInBlock;
  unsigned nDataUsed;
private:
  void calAvg (const std::vector<double > & vec,
	       double & my_avg,
	       double & my_error_avg);
public:
  void processData (const std::vector<double > & vec,
		    const unsigned & nBlock);
  double getAvg () const {return avg;}
  double getVar () const {return var;}
  double getAvgError () const {return error_avg;}
  double getVarError () const {return error_var;}
  unsigned getNumDataUsed () const {return nDataUsed;}
};


class BlockAverage_acc
{
  double avg;
  double var;
  double error_avg;
  unsigned nDataInBlock;
private:
  double sum;
  double sum2;
  double blockSum2;
  unsigned nBlock;
  double currentBlockSum;
  double currentSum2;
  unsigned currentNDataInBlock;
public:
  BlockAverage_acc ();
  BlockAverage_acc (const unsigned & nDataInBlock_);
  void clear ();
  void reinit (const unsigned & nDataInBlock_);
public:
  void deposite (const double & vv);
  void calculate ();  
  double getAvg () const {return avg;}
  double getVar () const {return var;}
  double getAvgError () const {return error_avg;}  
  unsigned getNumDataUsed () const {return nBlock * nDataInBlock;}
}
    ;


#endif
