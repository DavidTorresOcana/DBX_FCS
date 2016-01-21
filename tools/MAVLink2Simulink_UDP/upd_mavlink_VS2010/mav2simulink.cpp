#define S_FUNCTION_NAME  mav2simulink
#define S_FUNCTION_LEVEL 2
#define MATLAB_MEX_FILE

#include "udp_mavlink_rec.hpp"

#include "simstruc.h"


// We exepct the port number for UDP reception, the number of outputs and
// the sample frequency of the simulink block.
#define N_PARAMS 3

#define PORT_NUM_IDX     0    // The port to listen to 
#define SAMPLE_RATE_IDX  1    // Sample frequency for the block
#define MSG_OUT_IDX      2    // Number of output ports

#define MSG_OUT(S) ssGetSFcnParam(S, MSG_OUT_IDX)
#define SAMPLE_RATE(S) ssGetSFcnParam(S, SAMPLE_RATE_IDX)
#define PORT_NUM(S) ssGetSFcnParam(S, PORT_NUM_IDX)

/* Note from the frustrated developer:                                          */ 
/* Horrible stuff: this strings must match the string in the Mavlink debug vector
 * AND they must have the same order as in the simulink block. I need to fin a 
 * way to programatically inform simulink about the available messages and change
 * the block accordingly. As opposed to qgroundcontrol, no qSignals are available
 * to seamlessly handle this.*/ 
static  std::string keys[5] = {"accel", "gyro", "magn", "vispos", "visatt"};

static void mdlInitializeSizes(SimStruct *S)
{
    /* Number of expected parameters */
    ssSetNumSFcnParams(S, N_PARAMS);  
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
        return;

    /* No states in the block*/
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /* No inputs from Simulink */
    if (!ssSetNumInputPorts(S, 0)) return;
    
    int_T * msg_vector = (int_T *) mxGetData(MSG_OUT(S)); 
    int_T nOutputPorts = 0;
    for (int i = 0; i < mxGetNumberOfElements(MSG_OUT(S)); ++i)
      nOutputPorts += msg_vector[i];
    
    if (!ssSetNumOutputPorts(S, nOutputPorts)) return;
    
    /* All widths of data will be 4, x|y|z|time */
    for (int ii = 0; ii < nOutputPorts; ii++)
        ssSetOutputPortWidth(S, ii, 4); /* x, y, z, t */

    ssSetNumSampleTimes(S, 1);
    
    ssSetNumPWork(S, 1); /* Use a pointer to the udp_server class */
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);

    /* Specify the sim state compliance to be same as a built-in block */
    ssSetSimStateCompliance(S, DISALLOW_SIM_STATE);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetScalar(SAMPLE_RATE(S)));
    ssSetOffsetTime(S, 0, 0.0);
    ssSetModelReferenceSampleTimeDefaultInheritance(S);
}

#define MDL_START
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
{
  int port_num = (int) mxGetScalar(PORT_NUM(S));

  /* Will start the UDP thread immediatly */
  ssGetPWork(S)[0] = (void *) new udp_server( port_num );
  udp_server * udp_thread = (udp_server *) ssGetPWork(S)[0];
  //static char errMsg[512];
  //sprintf(errMsg, "Port %d is occupied. If port is correct, please wait some seconds and try again.\n",port_num);
  //if( !udp_thread->is_open() ) 
    //ssSetErrorStatus(S, errMsg);
  //else
    //ssPrintf("Port connected succesfully!\n");

}
#endif

static void mdlOutputs(SimStruct *S, int_T tid)
{
    udp_server * udp_thread = (udp_server *) ssGetPWork(S)[0];
    const msgs_map * current_data = udp_thread->get_latest_data();
    
    if (current_data->empty())
      return;

    int_T N, i, portN = 0;
    N = mxGetNumberOfElements(MSG_OUT(S));
    int_T * msg_vector = (int_T *) mxGetData(MSG_OUT(S)); 
    
    /* Iterate over the "boolean" parameter vector*/ 
    for (i = 0; i < N; ++i)
    {
      if (msg_vector[i])
      {
        msgs_map::const_iterator itMap = current_data->find(keys[i]);
        real_T* y = ssGetOutputPortRealSignal(S, portN);
        int w = ssGetOutputPortWidth(S, portN);
        
        if (itMap != current_data->end())
        {
          /*ssPrintf("msg_vector[%d] = %d. %s key found! Will output on port %d of width %d.\n",*/
              /*i, msg_vector[i], keys[i].c_str(), portN, w);*/
          y[0] = itMap->second.x;
          y[1] = itMap->second.y;
          y[2] = itMap->second.z;
          double timeT = (real_T)itMap->second.time_usec;
          y[3] = timeT/1e6;
        } else {
          for (int j = 0; j < w; ++j) y[j] = 0;
        }
        portN++;
      }
    }
}

static void mdlTerminate(SimStruct *S)
{
  udp_server * udp_thread = (udp_server *) ssGetPWork(S)[0];
  udp_thread->Close();
  delete udp_thread;
}

#ifdef  MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h" 
#endif
