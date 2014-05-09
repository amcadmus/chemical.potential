#include "BlockAverage.h"
#include <cmath>

void BlockAverage::
calAvg (const std::vector<double > & vec,
	double & my_avg,
	double & my_error_avg)
{
  my_avg = 0;
  for (unsigned i = 0; i < nDataUsed; ++i){
    my_avg += vec[i];
  }
  my_avg /= double(nDataUsed);

  std::vector<double > blockAverage;  
  for (unsigned i = 0; i < nBlock; ++i){
    double tmp = 0;
    for (unsigned j = 0; j < nDataInBlock; ++j){
      tmp += vec[i * nDataInBlock + j];
    }
    tmp /= double (nDataInBlock);
    blockAverage.push_back (tmp);
  }
  
  double sum2 = 0;
  for (unsigned i = 0; i < nBlock; ++i){
    sum2 += (blockAverage[i] - avg) * (blockAverage[i] - avg);
  }

  my_error_avg = sqrt (sum2 / (nBlock * (nBlock-1)));
}

void BlockAverage::
processData (const std::vector<double > & vec,
	     const unsigned & nBlock_)
{
  nBlock = nBlock_;
  unsigned nData = vec.size();
  nDataInBlock = nData / nBlock;
  nDataUsed = nDataInBlock * nBlock;

  calAvg (vec, avg, error_avg);
  
  std::vector<double > var_vec;
  for (unsigned i = 0; i < nDataUsed; ++i){
    double tmp = vec[i] - avg;
    var_vec.push_back (tmp * tmp);
  }
  calAvg (var_vec, var, error_var);

  var *= nDataUsed / (nDataUsed - 1.);
  error_var *= nDataUsed / (nDataUsed - 1.);
}


void BlockAverage_acc::
clear ()
{
  sum = sum2 = blockSum2 = currentBlockSum = currentSum2 = 0.;
  nBlock = currentNDataInBlock = 0;
}

void BlockAverage_acc::
reinit (const unsigned & nDataInBlock_)
{
  clear ();
  avg = var = error_avg = 0.;
  nDataInBlock = nDataInBlock_;
}

BlockAverage_acc::
BlockAverage_acc (const unsigned & nDataInBlock_)
{
  reinit (nDataInBlock_);
}

BlockAverage_acc::
BlockAverage_acc ()
{
  reinit (1);
}

void BlockAverage_acc::
deposite (const double & vv)
{
  currentBlockSum += vv;
  currentSum2 += vv * vv;
  currentNDataInBlock ++;
  if (currentNDataInBlock == nDataInBlock){
    currentBlockSum /= double (currentNDataInBlock);
    sum += currentBlockSum;
    blockSum2 += currentBlockSum * currentBlockSum;
    sum2 += currentSum2;
    nBlock ++;
    currentBlockSum = 0.;
    currentSum2 = 0.;
    currentNDataInBlock = 0.;
  }
}

void BlockAverage_acc::
calculate ()
{
  if (nBlock == 0){
    if (currentNDataInBlock != 0){
      avg = currentBlockSum / double(currentNDataInBlock);
    }
    return;
  }
  
  avg = sum / double (nBlock);

  if (nBlock == 1){
    return;
  }
  
  error_avg = ( blockSum2 - double(nBlock) * avg * avg ) / (double(nBlock) - 1.) / double(nBlock);
  error_avg = sqrt(error_avg);

  int totNumData = nBlock * nDataInBlock;
  var = (sum2 - double(totNumData) * avg * avg ) / (double(totNumData) - 1.); 
}


