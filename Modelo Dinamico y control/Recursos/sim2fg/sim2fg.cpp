/////////////////////////////////////////////////////////////////////
// Simulink 2 flightgear socket interface
//   uses native-fdm interface from flightgear
//
// $Author: simon $
// $Date: 2009-12-03 15:14:31 +0000 (Thu, 03 Dec 2009) $
//
// $Revision: 31 $
// 
// Blue Bear Systems Research Ltd
//
/////////////////////////////////////////////////////////////////////

#include <cmath>

#ifdef __cplusplus
extern "C" {
#endif

#define S_FUNCTION_NAME  sim2fg
#define S_FUNCTION_LEVEL 2

#include <windows.h>

#include "simstruc.h"

// include the flightgear net_fdm interface spec
#include "net_fdm.hxx"


// endian swap for floats and doubles
// assumes we are running on an intel machine
static void htond (double &x)	
{
	int    *Double_Overlay;
	int     Holding_Buffer;
   
	Double_Overlay = (int *) &x;
	Holding_Buffer = Double_Overlay [0];

	Double_Overlay [0] = htonl (Double_Overlay [1]);
	Double_Overlay [1] = htonl (Holding_Buffer);
}

// Float version
static void htonf (float &x)	
{
	int    *Float_Overlay;
	int     Holding_Buffer;

	Float_Overlay = (int *) &x;
	Holding_Buffer = Float_Overlay [0];

	Float_Overlay [0] = htonl (Holding_Buffer);
}


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
    ssSetNumSFcnParams(S, 2);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, 6);
    ssSetInputPortRequiredContiguous(S, 0, true); /*direct input signal access*/
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(S, 1);
	ssSetNumRWork(S, 0);
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
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}



#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetRealDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   */
  static void mdlInitializeConditions(SimStruct *S)
  {
  }
#endif /* MDL_INITIALIZE_CONDITIONS */
  

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
static void mdlStart(SimStruct *S)
{
	SOCKET	sClient;
	WSADATA wsd;
	SOCKADDR_IN server;
	struct hostent *host = NULL;

	// get the server address
	const mxArray *serverNameAry = ssGetSFcnParam(S, 0);
	int bufLen = mxGetM(serverNameAry)*mxGetN(serverNameAry)*sizeof(mxChar) + 1;
	char *serverName = new char[bufLen];
	// check that the second argument is a string and get it
	if (mxGetString(ssGetSFcnParam(S, 0), serverName, bufLen) == 1)
	{
		delete [] serverName;
		ssSetErrorStatus(S, "Something up with the address string");
		return;
	}

	// get the port number
	int iPort = static_cast<int>(mxGetScalar(ssGetSFcnParam(S, 1)));

	// load winsock
	if (WSAStartup(MAKEWORD(2, 2), &wsd) != 0)
	{
		ssSetErrorStatus(S, "Failed to load winsock library");
		return;
	}

	server.sin_family = AF_INET;
	server.sin_port = htons(iPort);
	server.sin_addr.s_addr = inet_addr(serverName);
	
	if (server.sin_addr.s_addr == INADDR_NONE)
	{
		host = gethostbyname(serverName);
		if (host == NULL)
		{
			ssSetErrorStatus(S, "Unable to resolve server");
			return;
		}
		memcpy((void *)&server.sin_addr, host->h_addr_list[0], host->h_length);
	}

	// connect to model server
	// load winsock

	// Create the socket
	sClient = socket(AF_INET, SOCK_DGRAM, 0);
	if (sClient == INVALID_SOCKET)
	{
		ssSetErrorStatus(S, "socket() failed");
		return;
	}

	// connect to the server
	if (connect(sClient, (SOCKADDR *)&server, sizeof(server)) == SOCKET_ERROR)
	{
		int connectErr = WSAGetLastError();
	}

	// put it into non-blocking mode
	unsigned long nonBlock = 1;
	int nRet = ioctlsocket(sClient, FIONBIO, &nonBlock);

	int bufsz = sizeof(double);
	setsockopt(sClient, SOL_SOCKET, SO_RCVBUF, (char *)&bufsz, sizeof(bufsz));

	// save the SOCKET for this instance
	ssGetIWork(S)[0] = static_cast<int>(sClient);
}
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    const real_T *u = (const real_T *) ssGetInputPortSignal(S, 0);

	// build up the data buffer
	FGNetFDM buf;
	memset(&buf, 0, sizeof(buf));
	buf.version = FG_NET_FDM_VERSION;

	// position and attitude
	buf.latitude = u[0];
	buf.longitude = u[1];
	buf.altitude = u[2];

	buf.phi = static_cast<float>(u[3]);
	buf.theta = static_cast<float>(u[4]);
	buf.psi = static_cast<float>(u[5]);

	// convert to network order
	buf.version = ntohl(buf.version);
	htond(buf.latitude);
	htond(buf.longitude);
	htond(buf.altitude);
	htonf(buf.phi);
	htonf(buf.theta);
	htonf(buf.psi);

	// send the input data to fg
	SOCKET sClient = ssGetIWork(S)[0];

	int ret = send(sClient, (char *) &buf, sizeof(buf), 0);
}



#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */



#undef MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
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
	SOCKET sClient;
    
	// close the socket
	sClient = ssGetIWork(S)[0];
	closesocket(sClient);
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

