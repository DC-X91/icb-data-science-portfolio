#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <float.h>
#include "multinest.h"
#include "engine.h"
#define  BUFSIZE 512

Engine *e = NULL;


/******************************************** loglikelihood routine ****************************************************/

// Input arguments
// ndim 						= dimensionality (total number of free parameters) of the problem
// npars 						= total number of free plus derived parameters
// context						void pointer, any additional information
//
// Input/Output arguments
// Cube[npars] 						= on entry has the ndim parameters in unit-hypercube
//	 						on exit, the physical parameters plus copy any derived parameters you want to store with the free parameters
//	 
// Output arguments
// lnew 						= loglikelihood

void LogLike(double *Cube, int *ndim, int *npars, double *lnew, void *context)
{

  mxArray *r_pars, *r_l;
  char obuffer[BUFSIZE+1];
  char ibuffer[BUFSIZE+1];
  char bb[BUFSIZE+1];      

  if (!e)
    if (!(e = engOpen("/apps/MATLAB/R2017a/bin/matlab -nodesktop -nosplash -nojvm"))) {
      fprintf(stderr, "\nCan't start MATLAB engine\n");
    }

  obuffer[BUFSIZE] = '\0';
  engOutputBuffer(e, obuffer, BUFSIZE);

  char * bx=bb;
  bx += snprintf(bb, BUFSIZE, "[");
  size_t i;
  for (i=0; i<*ndim; ++i)
    {
      bx+=snprintf(bx, bb+BUFSIZE-bx, "%f,", Cube[i]);
    }
  bx += snprintf(bx, bb+BUFSIZE-bx, "]");  
  snprintf(ibuffer, BUFSIZE, "[pars, ll]= get_loglike_rocdd(%i, %s);", *ndim, bb);
  printf("%s ...\n", ibuffer);
  engEvalString(e, ibuffer);
  
  if ((r_pars = engGetVariable(e,"pars")) == NULL)
    printf("Oops! You didn't create a variable pars.\n\n");
  else {
  }

  if ((r_l = engGetVariable(e,"ll")) == NULL)
    printf("Oops! You didn't create a variable ll.\n\n");
  else {
  }

  for (i=0; i<*ndim; ++i)
    {
      Cube[i]=((double *)mxGetData(r_pars))[i];
    }
  *lnew=((double *)mxGetData(r_l))[0];
  printf("%f [ok] \n", *lnew);  
}

/***********************************************************************************************************************/




/************************************************* dumper routine ******************************************************/

// The dumper routine will be called every updInt*10 iterations
// MultiNest doesn not need to the user to do anything. User can use the arguments in whichever way he/she wants
//
//
// Arguments:
//
// nSamples 						= total number of samples in posterior distribution
// nlive 						= total number of live points
// nPar 						= total number of parameters (free + derived)
// physLive[1][nlive * (nPar + 1)] 			= 2D array containing the last set of live points (physical parameters plus derived parameters) along with their loglikelihood values
// posterior[1][nSamples * (nPar + 2)] 			= posterior distribution containing nSamples points. Each sample has nPar parameters (physical + derived) along with the their loglike value & posterior probability
// paramConstr[1][4*nPar]:
// paramConstr[0][0] to paramConstr[0][nPar - 1] 	= mean values of the parameters
// paramConstr[0][nPar] to paramConstr[0][2*nPar - 1] 	= standard deviation of the parameters
// paramConstr[0][nPar*2] to paramConstr[0][3*nPar - 1] = best-fit (maxlike) parameters
// paramConstr[0][nPar*4] to paramConstr[0][4*nPar - 1] = MAP (maximum-a-posteriori) parameters
// maxLogLike						= maximum loglikelihood value
// logZ							= log evidence value from the default (non-INS) mode
// INSlogZ						= log evidence value from the INS mode
// logZerr						= error on log evidence value
// context						void pointer, any additional information

void dumper(int *nSamples, int *nlive, int *nPar, double **physLive, double **posterior, double **paramConstr, double *maxLogLike, double *logZ, double *INSlogZ, double *logZerr, void *context)
{
	// convert the 2D Fortran arrays to C arrays
	
	
	// the posterior distribution
	// postdist will have nPar parameters in the first nPar columns & loglike value & the posterior probability in the last two columns
	
	int i, j;
	
	double postdist[*nSamples][*nPar + 2];
	for( i = 0; i < *nPar + 2; i++ )
		for( j = 0; j < *nSamples; j++ )
			postdist[j][i] = posterior[0][i * (*nSamples) + j];
	
	
	
	// last set of live points
	// pLivePts will have nPar parameters in the first nPar columns & loglike value in the last column
	
	double pLivePts[*nlive][*nPar + 1];
	for( i = 0; i < *nPar + 1; i++ )
		for( j = 0; j < *nlive; j++ )
			pLivePts[j][i] = physLive[0][i * (*nlive) + j];
}

/***********************************************************************************************************************/




/************************************************** Main program *******************************************************/



int main(int argc, char *argv[])
{
	int i;
	// char date_string[20];
	// time_t now = time(NULL);
	// strftime(date_string, 20, "%Y%m%d", localtime(&now));
	
	// set the MultiNest sampling parameters
	
	
	int IS = 0;					// do Nested Importance Sampling?
	
	int mmodal = 1;					// do mode separation?
	
	int ceff = 0;					// run in constant efficiency mode?
	
	int nlive = 1000;				// number of live points (default 1000)
	
	double efr = 0.3;				// set the required efficiency
	
	double tol = 0.5;				// tol, defines the stopping criteria
	
	int ndims = 5;					// dimensionality (no. of free parameters)
	
	int nPar = 5;					// total no. of parameters including free & derived parameters
	
	int nClsPar = 5;				// no. of parameters to do mode separation on
	
	int updInt = 10;				// after how many iterations feedback is required & the output files should be updated
							// note: posterior files are updated & dumper routine is called after every updInt*10 iterations
	
	double Ztol = -1E90;				// all the modes with logZ < Ztol are ignored
	
	int maxModes = 100;				// expected max no. of modes (used only for memory allocation)
	
	int pWrap[ndims];				// which parameters to have periodic boundary conditions?
	for(i = 0; i < ndims; i++) pWrap[i] = 0;
	
        char root[100] = "chains/rocdd-mom-sim250_"; // root for output files

	int seed = -1;					// random no. generator seed, if < 0 then take the seed from system clock
	
	int fb = 1;					// need feedback on standard output?
	
	int resume = 0;					// resume from a previous job?
	
	int outfile = 1;				// write output files?
	
	int initMPI = 1;				// initialize MPI routines?, relevant only if compiling with MPI
							// set it to F if you want your main program to handle MPI initialization
	
	double logZero = -DBL_MAX;			// points with loglike < logZero will be ignored by MultiNest
	
	int maxiter = 0;				// max no. of iterations, a non-positive value means infinity. MultiNest will terminate if either it 
							// has done max no. of iterations or convergence criterion (defined through tol) has been satisfied
	
	void *context = 0;				// not required by MultiNest, any additional information user wants to pass

	
	
	// calling MultiNest
	
	run(IS, mmodal, ceff, nlive, tol, efr, ndims, nPar, nClsPar, maxModes, updInt, Ztol, root, seed, pWrap, fb, resume, outfile, initMPI, 
	logZero, maxiter, LogLike, dumper, context);
}

/***********************************************************************************************************************/
