/*=========================================================
 * matrixDivideComplex.c - Example for illustrating how to use 
 * complex numbers in a LAPACK function called from a C MEX-file.
 *
 * X = matrixDivideComplex(A,B) computes the solution to a 
 * complex system of linear equations A * X = B
 * computes the solution to a complex system of linear equations 
 * using LAPACK routine ZGESV, where
 * A is an N-by-N matrix  
 * X and B are N-by-1 matrices.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 2009-2010 The MathWorks, Inc.
 *=======================================================*/

#if !defined(_WIN32)
#define zgesv zgesv_
#endif

#include "mex.h"
#include "lapack.h"
#include "fort.h"      /* defines complex data handling functions */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *zinA, *zinB;  /* pointers to input matrices */

    /* matrix dimensions - use variable names from ZGESV arguments */
    size_t lda, nda, ldb, nColumns;
            
    /* additional inputs to ZGESV */
    mxArray *mxPivot;
    mwSignedIndex *iPivot;
    mwSignedIndex dims[2];
    mwSignedIndex info=0;
    
    /* Check for proper number of arguments. */
    if ( nrhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:rhs",
            "This function requires 2 input matrices.");
    }
    /* Check for complex values */
    if (!mxIsComplex(prhs[0]) | !mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:real",
            "Input matrices must be complex.");
    }
    
    /* dimensions of input matrix A */
    lda = mxGetM(prhs[0]);  
    nda = mxGetN(prhs[0]);
    /* dimensions of input matrix B */
    ldb = mxGetM(prhs[1]);  
    nColumns = mxGetN(prhs[1]);

    /* Validate input arguments */
    if (lda != nda) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:square",
            "LAPACK function requires input matrix 1 must be square.");
    }
    if (ldb != nda) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:matchdims",
            "Inner dimensions of matrices do not match.");
    }
    if (nColumns != 1) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:zerodivide",
            "For this example input matrix 2 must be a column vector.");
    }

    /* Convert complex input data to Fortran format */
    zinA = mat2fort(prhs[0], lda, nda);
    zinB = mat2fort(prhs[1], ldb, nColumns);

    /* Create iPivot argument for ZGESV */
    dims[0] = lda;
    dims[1] = nda;
    mxPivot = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxCOMPLEX);
    iPivot = (mwSignedIndex*)mxGetData(mxPivot);

    /* Call LAPACK function */
    zgesv(&lda, &nColumns, zinA, &lda, iPivot, zinB, &ldb, &info);
    if (info != 0) {
        mexErrMsgIdAndTxt("MATLAB:matrixDivideComplex:zgesv","zgesv failed.");
    }
  
    /* Convert Fortran output data to MATLAB format */ 
    /* fort2mat creates an mxArray for plhs[0] */
    plhs[0] = fort2mat(zinB, lda, lda, nColumns);
    /* plhs[0] now holds X */
  
    mxDestroyArray(mxPivot);
    mxFree(zinA);
    mxFree(zinB);
}
