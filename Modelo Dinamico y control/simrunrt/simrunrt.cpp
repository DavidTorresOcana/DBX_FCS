/**
 * \file        simrunrt.cpp
 * \brief       Simulink run real time widget - if we can, run at real time or at some time ratio
 * \author      simon
 * \date        01 March 2013, 10:24
 *
 * Last Modified details:
 * $Author: simon.willcox $
 * $Date: 2013-03-01 16:33:41 +0000 (Fri, 01 Mar 2013) $
 * $Revision: 16170 $
 *
 * \copyright
 * Blue Bear Systems Research
 * 
 */

#include <cmath>

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif


#ifdef __cplusplus
extern "C" {
#endif

#define S_FUNCTION_NAME  simrunrt
#define S_FUNCTION_LEVEL 2

#include <windows.h>

#include "simstruc.h"

/*====================*
 * S-function methods *
 *====================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, 0)) return;

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 1);
    ssSetNumIWork(S, 4);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, 0);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    //ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


#undef MDL_INITIALIZE_CONDITIONS
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
}
#endif /* MDL_INITIALIZE_CONDITIONS */


#define MDL_START
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution
   */
static void mdlStart(SimStruct *S)
{
	// get timer info
	LARGE_INTEGER tFreq;
	QueryPerformanceFrequency(&tFreq);

	// save it away
	ssGetIWork(S)[0] = tFreq.LowPart;
	ssGetIWork(S)[1] = tFreq.HighPart;

	// get first count
	LARGE_INTEGER startCount;
	QueryPerformanceCounter(&startCount);
	ssGetIWork(S)[2] = startCount.LowPart;
	ssGetIWork(S)[3] = startCount.HighPart;

	// get start time
	ssGetRWork(S)[0] = ssGetT(S);
}
#endif /*  MDL_START */


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	// try to run in (near) real time?
	// get the time scale factor
	double tFactor = mxGetScalar(ssGetSFcnParam(S, 0));
	if (tFactor < 0.01)
	{
		tFactor = 1.0;
	}
	tFactor = 1.0/tFactor;

	// get the current performance counter value
	LARGE_INTEGER thisCount, firstCount;
	QueryPerformanceCounter(&thisCount);
	firstCount = thisCount;
	
	LARGE_INTEGER tFreq;
	tFreq.LowPart = ssGetIWork(S)[0];
	tFreq.HighPart = ssGetIWork(S)[1];

	LARGE_INTEGER oldCount;
	oldCount.LowPart = ssGetIWork(S)[2];
	oldCount.HighPart = ssGetIWork(S)[3];

	double oldTime = ssGetRWork(S)[0];
	double thisTime = ssGetT(S);

	// save it away as next oldTime
	ssGetRWork(S)[0] = thisTime;

	// scale them by the factor
	thisTime *= tFactor;
	oldTime *= tFactor;

	// number of counts this time step
	LARGE_INTEGER nCounts;
	nCounts.QuadPart = (thisTime - oldTime)*tFreq.QuadPart;
	oldCount.QuadPart = oldCount.QuadPart + nCounts.QuadPart;

	while (thisCount.QuadPart < oldCount.QuadPart)
	{
		Sleep(0);
		QueryPerformanceCounter(&thisCount);
	}

	// save old count
	ssGetIWork(S)[2] = oldCount.LowPart;
	ssGetIWork(S)[3] = oldCount.HighPart;
}


#undef MDL_UPDATE
#if defined(MDL_UPDATE)
static void mdlUpdate(SimStruct *S, int_T tid)
{
}
#endif /* MDL_UPDATE */


#undef MDL_DERIVATIVES
#if defined(MDL_DERIVATIVES)
static void mdlDerivatives(SimStruct *S)
{
}
#endif /* MDL_DERIVATIVES */


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
}

/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

#ifdef __cplusplus
}
#endif
