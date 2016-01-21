/****************************************************
* This is a MEX-FILE for matlab. 
*
* -- Foe Educational Use Only
* Credits:
*   -Serial communication part based on SerialIO.cpp, last updated by
*    Lorgio Teodovich, november 2009, available at MATLAB Central
*
*****************************************************/



/*******************
*Includes
*******************/
#include <windows.h>

#undef EXTERN_C

#include <process.h>
#include "mex.h"
#include "string.h"
#include "matrix.h"

#define WIN32_LEAN_AND_MEAN

#define MAVLINK_CRC_EXTRA 1
#define NATIVE_BIG_ENDIAN
#include "include/mavlink/v1.0/common/mavlink.h"
#include "include/mavlink/v1.0/mavlink_types.h"
#include "include/mavlink/v1.0/common/common.h"

#include "time.h"
// Can't include Message_Decoder here because haven't made structs yet
// #include "Message_Decoder.h" // after structs initialized

//From mxcreatestructarray.c - This means array/struct sizes can change without having to change all code
#define NUMBER_OF_VEHICLES (sizeof(Vehicles)/sizeof(struct Vehicle))
#define NUMBER_OF_FIELDS (sizeof(Vehicle_field_names)/sizeof(*Vehicle_field_names))
#define NUMBER_OF_MESSAGES (sizeof(Messages)/sizeof(struct Message))
#define NUMBER_OF_FIELDS (sizeof(Vehicle_field_names)/sizeof(*Vehicle_field_names))

/*******************
*Global Declarations
*******************/

HANDLE hCom = NULL; // Handle for communications port

char *InputBuffer;  // pointer to Bytes read from serial port in ReadAllBytes function
int BytesToRead;    // In read all bytes, this will be equal to bytes available.  
                    // Must be passed to keep track of number of bytes read.


const int Max_Num_Vehicles = 5;       // This is to set size of variables in initialization
int Current_Number_Vehicles = 0;// This will keep track of how many vehicles currently exist
const int Max_Route_Length = 16;

// UPDATE these if changing fields!
const char *Vehicle_field_names[] = {"updated","ID","Component_ID","type","AP_type","base_mode","custom_mode","roll", "pitch", "yaw", "lat","lon","alt","hdg","action","nav_bearing","target_bearing","target_distance","nav_roll","nav_pitch","nav_yaw","voltage_battery"};

//From mxcreatestructarray.c
struct Vehicle
{
  bool updated;
  uint8_t ID;
  uint8_t Component_ID;
  uint8_t type;
  uint8_t AP_type;
  uint8_t base_mode;
  uint32_t custom_mode;
  float roll;
  float pitch;
  float yaw;
  float lat;
  float lon;
  float alt;
  uint16_t hdg;
  uint8_t action;
  int16_t nav_bearing;
  int16_t target_bearing;
  uint16_t target_distance;
  float nav_roll;
  float nav_pitch;
  float nav_yaw;
  uint16_t voltage_battery;
  
};

struct Ground_Station {        // probably only need one, still a struct?
    uint8_t ID;                 //  System ID, MP used 255
    uint8_t Component_ID;       //  Component ID, 190 means Mission Planner 
    uint8_t type;               //  GCS is type 6, FW is type 1
    uint8_t Autopilot_type;     //  8 is type invalid
    uint8_t mode;               //  1 is custom, 4 is auto
    uint8_t system_state;       //  0 is unknown/uninitialized
    uint32_t custom_mode;       //  I don't know what this does, in heartbeat
    
};

const struct Vehicle Default_Vehicle = {
    0,  // Updated defaults to 0
    0,  // Vehicle ID, nonexistant vehicles are zeroed
    0,  // Component ID, 0 is all
    1,  // Vehicle type is 1 = FW
    3,  // Vehicle autopilot is 3 = APM
    0,  // Roll
    0,  // Pitch
    0,  // Yaw
    0,  // Lat
    0,  // Lon
    0,  // Alt
    0,  // action
    0,  // nav_bearing
    0,  // target_bearing
    0,  // target_distance
    0,  // nav_roll
    0,  // nav_pitch
    0,  // target_yaw
    0  // voltage_battery
            
};
    
const struct Ground_Station GCS = {
    
    255,    // This is my ID, I am the GCS
    190,    // 190 is MissionPlanner - seems somewhat appropriate?            
    6,      // GCS type is 6.  FW type is 1
    8,      // 8 is for invalid autopilot, like a GCS
            //with no autopilot. APM is autopilot type 3
    1,      // Mode 1 is custom, Mode 4 is auto, 
            //Don't know if GCS needs mode...
    0,      // Changed to 0 which is unknown/uninitialized.  Snooped MP 
            // heartbeats are 0.
    0       // Custom Mode.  Not used?
};
   
struct Vehicle Vehicles[Max_Num_Vehicles];
    
// Vehicle This_Vehicle = Default_Vehicle; // So I can deal with one at a time

#include "Message_Decoder.h" // This is switch/case for handling incoming messages
// needs to be after declaring Vehicles

/*******************
*Functions
*******************/

void closeSerial() { // Closes serial port
    if(!(hCom==NULL)){
        CloseHandle(hCom);
        hCom = NULL;
    }
}

/******************
* Format copied from original Receive function.
*
 * This function looks at serial port, determines how many bytes are in 
 * buffer, reads all the bytes available using overlapped I/O
 * copies info from serial port to InputBuffer
 * returns -- currently being modified.  Should be success/fail or number 
 * of bytes read.
 */
    int ReadAllBytes() { // Reads All available bytes from Serial port
        
    DWORD mask;
    COMSTAT lpCS;
    BOOL Successful;
    OVERLAPPED o;
    
    //Initialization and Set-Up
    ZeroMemory(&o,sizeof(o));
    
    // create event for overlapped I/O
    // Since comm port is set up for overlapped I/O, all functions relating to it
    // also must be built using overlapped I/O
    o.hEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
    if(o.hEvent == INVALID_HANDLE_VALUE) mexErrMsgTxt("Failed to create overlapped event");
    
    // This provides number of bytes in the read buffer
    // see COMSTAT struct for other components in lpCS
    Successful = ClearCommError(hCom, NULL, &lpCS);
    if(!Successful) {
        printf("Clear Comm Error Failed, E = %d \n", GetLastError());
        mexErrMsgTxt("Clear Comm Error");
    }
    DWORD BytesAvailable = lpCS.cbInQue; 

    BytesToRead = BytesAvailable;
    if (BytesToRead == 0){ // if no bytes, don't read, and tell me
     printf("No bytes to read");   
    }
    else{ // if there are bytes to read, read them
    //Get the Data
    while(1)   {  // While exists only so breaks can be used to terminate.
                  // I don't think a loop would ever actually happen
         
        // get the event mask
        Successful = WaitCommEvent(hCom, &mask, &o);
        
        if( !Successful ) {
            DWORD e = GetLastError();    // Reading GetLastError clears it
                                        // used in one of two places, so can't call in-line
            if( e == ERROR_IO_PENDING ) {   // ERROR_IO_PENDING is 997
                DWORD r;
                Successful = GetOverlappedResult(hCom,&o,&r,TRUE);                
                if( !Successful ) {
                    printf("GetOverlappedResults Failed \n");
                    return 0; // failed, return unsuccessful
                    break;
                }
            }
            else {
                printf("WaitCommEvent failed with error %d. \n", e);
                return 0; // failed, return unsuccessful
                break;
            }
        }
        
        //There was an error getting the mask.
        if(mask == 0) {
            printf("mask == 0\n");
            return 0; // failed, return unsuccessful
            break;
        }
        
        // if we got the mask, and the flag indicates a character has been received
        if( mask & EV_RXCHAR) {
            
            DWORD NumToRead = BytesAvailable;
            
           // Bytes = new char[BytesAvailable];
            delete [] InputBuffer;
            InputBuffer = new char[BytesAvailable];  // This creates an array of size not known at compile.
                                    
                if (hCom == INVALID_HANDLE_VALUE){
                    printf("Read Fail, Invalid Handle, error: %d", GetLastError());
                    
                }
                                
                // Read Serial Port
                Successful = ReadFile(hCom,InputBuffer,BytesAvailable,NULL,&o);
                if( !Successful ){
                    DWORD Error = GetLastError();  // Reading changes it.  If not pending, then return
                    if( Error == ERROR_IO_PENDING ){ // IO_PENDING is 997
                        Successful = GetOverlappedResult(hCom,&o,NULL,TRUE);
                        if( !Successful ){
                            // This is error from GetOverlappedResult
                            printf("GetOverlappedResult Error = %d \n", GetLastError());
                            return 0; // failed, return unsuccessful
                            break; // kick out of While
                        }
                    }
                    else { // This is Readfile Error if it wasn't IO_PENDING
                        printf("ReadFile Failed, error = %d \n", Error); 
                        return 0; // failed, return unsuccessful
                        break;
                    }
                }
                
                return BytesAvailable;  // was returning oneByte.  Should be either success/fail
                                        // or use to return Bytes Available instead of global variable
                
              }        
        mask = 0; //Clear Mask
    } // End While
    } // end if/else bytes to read
    
    CloseHandle(o.hEvent);   //Close the Event
} // End Receive Function

    
/******************************************************
 * openSerial Function
 *
 ******************************************************/

void openSerial(char *portname, int CBR_baud){  // Opens serial port, sets states
    
    char portname_w32[255];
    COMMCONFIG lpCC;
    COMMTIMEOUTS lpTo;
    BOOL Successful;
//     SerialData[0]=1;
    sprintf(portname_w32, "\\\\.\\%s", portname);
    
    if (hCom != NULL) { // If the port is already open, close it
        printf("Port already open, closing port\n");
        closeSerial();
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    // Open the port
    hCom = CreateFile(portname_w32, GENERIC_READ|GENERIC_WRITE, 0, NULL,
            OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
    
    if (hCom == INVALID_HANDLE_VALUE) { // Check if port opened successfully
        printf("Failed to open port\n");
        hCom = NULL;                    // If invalid, then null
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    mexAtExit(closeSerial); // This ensures the serial port gets closed on termination
    
    // Get states before setting them
    Successful = GetCommState( hCom, &lpCC.dcb);  
    if (!Successful){ 
        printf("Get Comm State failed, error %d.\n", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    
    // Define states
    lpCC.dcb.BaudRate = CBR_baud;
    lpCC.dcb.ByteSize = 8;
    lpCC.dcb.StopBits = ONESTOPBIT;
    lpCC.dcb.Parity = NOPARITY;
    lpCC.dcb.fDtrControl = DTR_CONTROL_DISABLE;
    lpCC.dcb.fRtsControl = RTS_CONTROL_DISABLE;
    
    // Set defined states
    if(!SetCommState( hCom, &lpCC.dcb )){
        printf("Set Comm State failed, current error %d.\n", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    // Get timeouts before setting them
    Successful = GetCommTimeouts(hCom, &lpTo);
    if(!Successful) {
        printf("GetCommTimeouts Failed, error = %d.", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    
    
    // Define timeouts
    lpTo.ReadIntervalTimeout = 0;
    lpTo.ReadTotalTimeoutMultiplier = 10;
    lpTo.ReadTotalTimeoutConstant = 10;
    lpTo.WriteTotalTimeoutMultiplier = 10;
    lpTo.WriteTotalTimeoutConstant = 100;
    
    // Set defined timeouts
    Successful = SetCommTimeouts(hCom, &lpTo);
    if(!Successful) {
        printf("SetCommTimeouts Failed, error = %d.", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    
    
    Successful = SetupComm(hCom, 2048, 2048);
    if(!Successful) {
        printf("SetupComm Failed, error = %d. \n", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    
    Successful = SetCommMask(hCom, EV_RXCHAR);
    if(!Successful) {
        printf("SetCommMask Failed, error = %d.\n", GetLastError());
//         SerialData[0]=0; // Return 0 for failure
        return;
    }
    
} // End OpenSerial

/***********************************
 * writeMessage based on original writeSerial
 * several repeated portions from building message brought in
 */
int writeMessage(mavlink_message_t tx_msg) {
    
    if (hCom == NULL) printf("Cannot write. Open serial port first\n");
    else {
                BOOL Successful;
                OVERLAPPED oW; // Overlapped Write
                oW.hEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
                if(oW.hEvent == INVALID_HANDLE_VALUE) printf("Failed to create overlapped event");
                
                uint8_t buf[MAVLINK_MAX_PACKET_LEN] = {0}; // From http://qgroundcontrol.org/dev/mavlink_onboard_integration_tutorial
                                                           // I added {0} to zero array.  SHould probably do after transmission, also 

                mavlink_msg_to_send_buffer(buf, &tx_msg);  // LENGTH note: payload length is 18, but there are 6 places in front 
                                                           // plus 2 at end (checksum, I think)
                                                           // MAVLINK_NUM_NON_PAYLOAD_BYTES is defined as number of these extra bytes

                int BytesToWrite = tx_msg.len+MAVLINK_NUM_NON_PAYLOAD_BYTES;
                
                const char *char_buf = reinterpret_cast<char*>(buf);
                
                Successful = WriteFile(hCom, char_buf, BytesToWrite, NULL, &oW);  // Overlapped
                
                if(!Successful) {
                    DWORD Error = GetLastError();
                    if( Error == ERROR_IO_PENDING ){
                        
                        DWORD bytes_written;
                        Successful = GetOverlappedResult(hCom,&oW,&bytes_written,TRUE);
                        
                        if (!Successful) {printf("Overlapped fail, error = %d\n", GetLastError());
                        mexEvalString("drawnow;");
                        }
                    }
                    else{
                        printf("WriteFile failed, error =  %d. \n", Error);
                    }
                }
    
    
    if(!Successful) {
        printf("WriteFile failed, error =  %d.", GetLastError());
        return 0;
    }
    return BytesToWrite;
    } // end if else
} // End writeMessage




/**************************************************************************
 *This Mex sends and receives MAVLINK Messages across a serial port
 *
 *
 * 
 *************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    printf("In Mex\n");
    mexEvalString("drawnow;");
    
    bool Successful = FALSE;
    char *commandName;
    int commandNum = 0;
    char *prPortName;
    int Length0, i;
    mxArray *InArray;
    double *xValues;
    char *xCharData;
    int Baud;
    DWORD InQueue, OutQueue;
    int Comp_ID = 0;  // This is all components.  Should check and see if I need to specify on MATLAB side or can be all
    
    // These might go into the readmessage part, otherwise, the plhs part always causes an output
    mwSize dims[2] = {1, Max_Num_Vehicles};
    for (i = 0; i<Max_Num_Vehicles; i++){
        Vehicles[i] = Default_Vehicle;
    }
    
    /* Create a 1-by-n array of structs. */ 
    plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, Vehicle_field_names);
    
    
    // This output setup was from original program.  Trying matrix output setup inside readmessage
//     
// //     const char **fnames;       /* pointers to field names */ 
//      double *fout; // pointer to a double
//      
//     mwSize ndim = 2;    // Arrays will use 2-d minimum
//     
//     if(nlhs == 1) {  // if output is requested, allocate array
//         
//         plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL); // initialized for single number
//         SerialData = mxGetPr(plhs[0]);  // Point SerialData to output
//         SerialData[0] = 0; // initialize 0 for failure, success not yet achieved
// //         SerialData[1] = 0;
//         
//     } else if(nlhs == 2) {  // if output is requested, allocate array
//         
//         plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL); // initialized for single number
//         SerialData = mxGetPr(plhs[0]);  // Point SerialData to output
//         SerialData[0] = 0; // initialize 0 for failure, success not yet achieved
//         plhs[1] = mxCreateNumericArray(ndim, dims,mxDOUBLE_CLASS,mxREAL);
//         fout = mxGetPr(plhs[1]);
//         fout[0] = 1; // I think the attitude.roll later needs to be *fout
//         fout[1] = 1; // because attitude.roll is a pointer.
//         fout[2] = 1;// NOT CORRECT - *fout[0] doesn't work, while fout[0] does?
//         fout[3] = 1;// altitude
//         
//     }
    
    //Convert the Inputs
    if(nrhs >= 1){
        commandName = (char *) mxArrayToString(prhs[0]);
        // If command is open and 3 inputs
        if( (strcmp(commandName,"open")== 0)&&(nrhs == 3)){
            //Get Port
            if( (mxIsChar(prhs[1]) != 1) || (nrhs!= 3) ){
                printf("Invalid Open syntax.\n");
            }
            else{
                
                Length0 = mxGetN(prhs[1])+1;
                prPortName =(char *) mxCalloc(Length0, sizeof(char));
                mxGetString(prhs[1],prPortName,Length0);
                Baud = (int)mxGetScalar(prhs[2]); //Get Baud
//                 SerialData[0] = 1;  // output 1 for success, failures in
                                    //openSerial will change to 0
                openSerial(prPortName, Baud);
            }
        }
           
        // Send Ping message
        else if( (strcmp(commandName,"ping")== 0)){
            if(nrhs != 1){
                printf("Invalid ping syntax\n");
            }
            else{
                
                mavlink_message_t tx_msg;
                time_t ltime;
                uint64_t time_usec = time(&ltime);
                
                mavlink_msg_ping_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        ltime, 1, 0, 0);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        else if( (strcmp(commandName,"RequestDataStream")== 0)){
            if(nrhs != 5){
                printf("Invalid Data Stream Syntax syntax\n");
            }
            else{
                
                // Stream_ID:
                // 0: all
                // 1: 27,29 - Raw IMU, Scaled Pressure
                // 2: 1,42, 24, 62 - SYS_STATUS, MISSION_CURRENT, GPW_RAW_INT, NAV_CONTROLLER_OUTPUT
                // 3: 36, 35 - RC_CHANNELS_RAW, SERVO_OUTPUT_RAW
                // 4: 34 - RC_CHANNELS_SCALED
                // 5: none
                // 6: 33 - GLOBAL_POSITION_INT - Use This One!!!!!!!!!!!
                // 7: none
                // 8: none
                // 9: none
                // 10: 30 (attitude)
                // 11: 74 (VFR Hud)
                // 12: none
                
                // Message Rate: times per second to transmit data
                // start_stop: 1 for on, 0 for off.
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint8_t stream_ID = (int)mxGetScalar(prhs[2]); 
                uint8_t message_rate = (int)mxGetScalar(prhs[3]);     
                uint8_t start_stop = (int)mxGetScalar(prhs[4]);     
                
                mavlink_message_t tx_msg;
                mavlink_msg_request_data_stream_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, 0, stream_ID, message_rate, start_stop); // 0 for component is all
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        
        
        else if( (strcmp(commandName,"SetMode")== 0)){ // Set autopilot mode (Auto, manual, etc.)
            if(nrhs != 4){
                printf("Invalid Set Mode syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint8_t base_mode = (int)mxGetScalar(prhs[2]); // Mode, set using bit flags, 
                                                               // 4 (00000100) is auto
                uint8_t custom_mode = (int)mxGetScalar(prhs[3]); // Mode, set using bit flags, 
                                                               // 4 (00000100) is auto
                        
                mavlink_message_t tx_msg;
                mavlink_msg_set_mode_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, base_mode, custom_mode);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        else if( (strcmp(commandName,"MissionCount")== 0)){ // MP does this before sending new points
            if(nrhs != 3){
                printf("Invalid Mission Count Syntax syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint16_t count = (int)mxGetScalar(prhs[1]); // Sequence
                        
                mavlink_message_t tx_msg;
                mavlink_msg_mission_count_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID, count);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        
        else if( (strcmp(commandName,"MissionItem")== 0)){
            if(nrhs != 14){
                printf("Invalid Mission Item Syntax syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint16_t seq = (int)mxGetScalar(prhs[2]); // Sequence
                uint8_t frame = (int)mxGetScalar(prhs[3]); // 0 = Global, 1 = local NED, 2 = Mission (no frame) 3 = Global/relative alt, 4 = local ENU
                uint16_t command = (int)mxGetScalar(prhs[4]); // command number, see MAV_CMD
                uint8_t current = (int)mxGetScalar(prhs[5]); // is this current mission? 1 = true
                uint8_t autocontinue = (int)mxGetScalar(prhs[6]); // 1 = true
                float param1 = (float)mxGetScalar(prhs[7]); // radius of mission item, hor far away is 'reached'
                float param2 = (float)mxGetScalar(prhs[8]); // how long to stay inside radius until proceeding (RW only?)
                float param3 = (float)mxGetScalar(prhs[9]); // for Loiter - radius to orbit.  positive = CW
                float param4 = (float)mxGetScalar(prhs[10]); // Yaw orientation (RW only?)
                float x = (float)mxGetScalar(prhs[11]);
                float y = (float)mxGetScalar(prhs[12]);
                float z = (float)mxGetScalar(prhs[13]);
                        
                mavlink_message_t tx_msg;
                mavlink_msg_mission_item_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID, seq, frame, command, current, autocontinue, param1, param2, param3, param4, x, y, z);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        
            // Send mission request list message asks for list of missions
            // specific requests for mission information need to include which one.
        else if( (strcmp(commandName,"missionrequestlist")== 0)){
            if(nrhs != 2){
                printf("Invalid mission request list syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                
                mavlink_message_t tx_msg;
                
                mavlink_msg_mission_request_list_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        // Should start by identifying how many things to write, then waiting for response
        else if( (strcmp(commandName,"missionwritelist")== 0)){
            if(nrhs != 4){
                printf("Invalid mission write list syntax\n");
            }
            else{
                
                mavlink_message_t tx_msg;
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint16_t start_index = (int)mxGetScalar(prhs[2]); 
                uint16_t end_index = (int)mxGetScalar(prhs[3]);    
                
                mavlink_msg_mission_write_partial_list_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID, start_index, end_index);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        
                    // Send mission request asks for information on specific mission
        else if( (strcmp(commandName,"missionrequest")== 0)){
            if(nrhs != 3){ // must include which mission to look for
                printf("Invalid mission request list syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                uint16_t sequence = (int)mxGetScalar(prhs[2]);
                mavlink_message_t tx_msg;
                
                mavlink_msg_mission_request_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                       Sys_ID, Comp_ID, sequence);
                
                int BytesWritten = writeMessage(tx_msg);
            }    
        }
        
        // This currently uses the _command_long_ message to send a command
        // Any command is possible, I built for NAV_WAYPOINT, which is 16
        else if( (strcmp(commandName,"missioncmd")== 0)){
            if(nrhs != 10){ 
                printf("Invalid mission write syntax\n");
            }
            //MAV_CMD_NAV_WAYPOINT 
            // Param #1 - Hold time in decimal seconds for Rotary (ignor for FW)
            // Param #2 - Acceptance radius in Meters (how close before you are 'there')
            // Param #3 - how far away to pass (radius in Loiter) use 0 to pass over, + for CW, - for CCW
            // Param #4 - Yaw Angle - rotary (ignored, or zero, or null?)
            // Param 5, 6, 7 - Lat, Long, Alt
            
            // NOTE: if use mission point instead, can be given in local coords
            
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                int command = (int)mxGetScalar(prhs[2]); // prhs counts from 0 up.  number 1 is the second
                float p1 = (float)mxGetScalar(prhs[3]);     
                float p2 = (float)mxGetScalar(prhs[4]);
                float p3 = (float)mxGetScalar(prhs[5]);
                float p4 = (float)mxGetScalar(prhs[6]);
                float p5 = (float)mxGetScalar(prhs[7]);
                float p6 = (float)mxGetScalar(prhs[8]);
                float p7 = (float)mxGetScalar(prhs[9]); // Reading a prhs past 
                                                        //what is input will compile, and then crash matlab
                
                uint8_t confirmation = 0; // some commands transmit multiple times for confirmation (like kill command)
                mavlink_message_t tx_msg;
                
                mavlink_msg_command_long_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID, command, confirmation, p1, p2, p3, p4, p5, p6, 0);
                
                                    printf("msg packed \n");
                                    mexEvalString("drawnow;");
                int BytesWritten = writeMessage(tx_msg);
                                    printf("msg transmitted \n");
                                    mexEvalString("drawnow;");
            }    
        }
        
        
        
        // Send heartbeat message
        else if( (strcmp(commandName,"heartbeat")== 0)){
            if(nrhs != 1){
                printf("Invalid heartbeat syntax\n");
            }
            else{
                mavlink_message_t tx_msg;
                
                mavlink_msg_heartbeat_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        GCS.type, GCS.Autopilot_type, GCS.mode, GCS.custom_mode, GCS.system_state);
                                
                writeMessage(tx_msg);
                
            }    
        }
        
        else if( (strcmp(commandName,"clearmissions")== 0)){
            if(nrhs != 2){
                printf("Invalid clear mission syntax\n");
            }
            else{
                mavlink_message_t tx_msg;
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                
                mavlink_msg_mission_clear_all_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID);
                                
                writeMessage(tx_msg);
                
            }    
        }
        
        
                // Send change operator control message
        else if( (strcmp(commandName,"changecontrol")== 0)){
            if(nrhs != 2){
                printf("Invalid change control syntax\n");
            }
            else{
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                
                mavlink_message_t tx_msg;
                uint8_t control_request = 0; // what is control request?
                uint8_t version; // probably defined somewhere
                const char *passkey = "passkey";
                mavlink_msg_change_operator_control_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, control_request, version, passkey);
                                
                writeMessage(tx_msg);
                
            }    
        }
        
        
        else if( (strcmp(commandName,"readallparams")== 0)){
            if(nrhs != 2){
                printf("Invalid Read all Parameter syntax\n");
            }
            else{
                mavlink_message_t tx_msg;
                
                uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
                
                mavlink_msg_param_request_list_pack(GCS.ID, GCS.Component_ID, &tx_msg, 
                        Sys_ID, Comp_ID);
                                
                writeMessage(tx_msg);
                
            }
        }
        
        
        
// // // // // // // // // // // // // // // // //         // if command is set_roll_pitch_yaw_thrust and 3 inputs
// // // // // // // // // // // // // // // // //         // syntax is ('write', set_roll, set_pitch, set_yaw, set_thrust, target_system, target_component)
// // // // // // // // // // // // // // // // //         // angle inputs are in radians!!!!!!!!!!!!!!!
// // // // // // // // // // // // // // // // //         // nav_controller_output is in degrees.
// // // // // // // // // // // // // // // // //         else if( (strcmp(commandName,"set_roll_pitch_yaw_thrust")== 0)){
// // // // // // // // // // // // // // // // //             if(nrhs != 6){
// // // // // // // // // // // // // // // // //                 printf("Invalid set roll_pitch_yaw_thrust syntax\n");
// // // // // // // // // // // // // // // // //             }
// // // // // // // // // // // // // // // // //             
// // // // // // // // // // // // // // // // //             else if (hCom==NULL) {
// // // // // // // // // // // // // // // // //                 printf("Writefile Failed Port closed\n");
// // // // // // // // // // // // // // // // //             }
// // // // // // // // // // // // // // // // //             else{
// // // // // // // // // // // // // // // // //                 int i;
// // // // // // // // // // // // // // // // // 
// // // // // // // // // // // // // // // // // //                 DWORD bytesWritten;
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //             
// // // // // // // // // // // // // // // // //                 //Get Size
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //                 uint8_t Sys_ID = (int)mxGetScalar(prhs[1]); 
// // // // // // // // // // // // // // // // //                 float set_roll = (float)mxGetScalar(prhs[2]);
// // // // // // // // // // // // // // // // //                 float set_pitch = (float)mxGetScalar(prhs[3]);
// // // // // // // // // // // // // // // // //                 float set_yaw = (float)mxGetScalar(prhs[4]);
// // // // // // // // // // // // // // // // //                 float set_thrust = (float)mxGetScalar(prhs[5]);
// // // // // // // // // // // // // // // // // //                 uint8_t target_system = Vehicle_ID;
// // // // // // // // // // // // // // // // // //                 uint8_t target_component = Component_ID;
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //                 mavlink_message_t tx_msg;
// // // // // // // // // // // // // // // // //                 uint8_t buf[MAVLINK_MAX_PACKET_LEN] = {0}; // From http://qgroundcontrol.org/dev/mavlink_onboard_integration_tutorial
// // // // // // // // // // // // // // // // //                                                            // I added {0} to zero array.  SHould probably do after transmission, also 
// // // // // // // // // // // // // // // // //                 mavlink_msg_set_roll_pitch_yaw_thrust_pack(GCS.ID, GCS.Component_ID, &tx_msg,
// // // // // // // // // // // // // // // // // 						       Sys_ID, Comp_ID, set_roll, set_pitch, set_yaw, set_thrust);
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //                 mavlink_msg_to_send_buffer(buf, &tx_msg);  // LENGTH note: payload length is 18, but there are 6 places in front 
// // // // // // // // // // // // // // // // //                                                            // plus 2 at end (checksum, I think)
// // // // // // // // // // // // // // // // //                                                            // MAVLINK_NUM_NON_PAYLOAD_BYTES is defined as number of these extra bytes
// // // // // // // // // // // // // // // // // //Debugging - prints message                
// // // // // // // // // // // // // // // // // //                 for (i=1;  i<MAVLINK_MAX_PACKET_LEN;i++){
// // // // // // // // // // // // // // // // // //                     printf("%d ", buf[i]);
// // // // // // // // // // // // // // // // // //                 }
// // // // // // // // // // // // // // // // // //                 printf("\n");
// // // // // // // // // // // // // // // // // //                 int BytesToWrite = 24; // this is 6 plus 18.  should have been 26.
// // // // // // // // // // // // // // // // //                 
// // // // // // // // // // // // // // // // //                 writeMessage(tx_msg);
// // // // // // // // // // // // // // // // //             }
// // // // // // // // // // // // // // // // //         }
        //If command is read
        // 
        else if( (strcmp(commandName,"read")== 0)){

            // This did use Receive function, which was removed.  See previous versions
        }
        else if(strcmp(commandName,"close")== 0){
            if (nrhs != 1){
                printf("Invalid close syntax\n");
            }
            else if (hCom==NULL) {
                printf("Port already closed\n");   
            }
            else closeSerial();
        }
        else if(strcmp(commandName,"clearRX")== 0){
            if (nrhs != 1){
                printf("Invalid clearRX syntax\n");
            }
            else if (hCom==NULL) {
                printf("Port already closed\n");
            }
            else PurgeComm(hCom,  PURGE_RXABORT | PURGE_RXCLEAR);
        }
        else if(strcmp(commandName,"readmessage")== 0){
            if (nrhs != 1){
                printf("Invalid syntax\n");
            }
            else if (hCom==NULL) {
                printf("Serial Port not open.\n");
                
        mxArray *null_output;
        null_output = mxCreateDoubleMatrix(1,1,mxREAL);
        *mxGetPr(null_output) = 0;
        mxSetFieldByNumber(plhs[0],i,0,null_output);
            }
            else{
                
                printf("In read\n");
                mexEvalString("drawnow;");

                mavlink_status_t status;
                mavlink_message_t rx_msg;
                int chan = 0;
                BOOL msgReceived = FALSE;
                BOOL Updated = FALSE;
                int Attitude_Count = 0;
                int VFR_Count = 0;
                mavlink_message_info_t messageInfo[256]; ///< Message information
                mavlink_message_info_t Info[256] = MAVLINK_MESSAGE_INFO;
                
// This reads all available bytes, then parses them.  Reading all
// is fast, going back and reading each one individually is slow.
               int BytesRead =  ReadAllBytes();
               
               // Vehicles array is not remembering previously read vehicles, 
               // but current number is. This resets current number so that
               // every time a batch of vehicles is read, all the vehicles
               // are brand new to us.  
               /************************
               *FIX BETTER
               ************************/
               Current_Number_Vehicles = 0;
               
                 for(i=0;i<BytesToRead;i++){
                     
                     if (mavlink_parse_char(chan, InputBuffer[i], &rx_msg, &status))
                        {
                        msgReceived = TRUE;
                         printf(" %d",  rx_msg.msgid);
// debug                         printf("Received message with ID %d, sequence: %d from component %d of system %d \n",
// debug                                rx_msg.msgid, rx_msg.seq, rx_msg.compid, rx_msg.sysid);
                        
//                         This_Vehicle.ID = rx_msg.sysid;
//                         This_Vehicle.Component_ID = rx_msg.compid;
                        
                        /**************************************************
                         *This section identifies which index in the 
                         * Vehicles Array the ID belongs to.
                         *
                         * Also checks that 
                         **************************************************/
                        
                        int ID_index = 999;
                        int matched = 0;
                        
                        if (Current_Number_Vehicles == 0) {
                            Current_Number_Vehicles = 1;
                            Vehicles[0].ID = rx_msg.sysid;
                            ID_index = 0;
                            printf("I received my first message from a vehicle with ID = %d \n", rx_msg.sysid);
                            
                        } // end if current number = 0
                        else{ // Current number vehicles != 0
                        
                        for (int j = 0; j<Current_Number_Vehicles; j++){ // this should cycle from j = 0 to j = current-1, I think
                            if (Vehicles[j].ID == rx_msg.sysid){
                                if(matched) {
                                    // we have a problem, do something?
                                }
                                ID_index = j;
                                matched = 1;
                                printf("ID_index set to %d \n", j);
                            } // end if
                        } // end for
                        
                        if (!matched) {
                         // We have a new vehicle!  We should do something!    
                        // Let's add a vehicle
                            // index starts at zero, vehicles start at 1.  
                            // Setting index to current vehicles goes to 
                            // one index higher than we had before
                            ID_index = Current_Number_Vehicles; 
                            Vehicles[ID_index].ID = rx_msg.sysid; // Set the ID value
                            Current_Number_Vehicles++;
                            printf("I found a new vehicle with ID = %d !  That makes %d total vehicles", rx_msg.sysid, Current_Number_Vehicles);
                        } // end if not matched
                        } // end else current number vehicles not 0
                        matched = 0; // We matched this message, reset for next time    
                        // IntrepretMessage is in header now
                        InterpretMessage(rx_msg, "Vehicles",ID_index); // InterpretMessage is in Message_Decoder Header
                        
                        InterpretMessage(rx_msg, "printf",ID_index); // Can I do both of these? - Yes, I can.
                        
                        } // end if mavlink_parse
                 
                 } // end for
               
               
               // After the for loop has parsed all read bytes, send one return back
                        if (msgReceived) {
                            msgReceived = FALSE; // Reset
                            
//                             Vehicles[0].updated = This_Vehicle.updated;
//                             
//                             printf("\n Lat/lon/alt = %d/%d/%d \n", This_Vehicle.lat,This_Vehicle.lon,This_Vehicle.alt);
//                             if (This_Vehicle.lat){
//                                  printf("\n Lat/lon/alt = %i/%i/%u \n", This_Vehicle.lat,This_Vehicle.lon,This_Vehicle.alt);
//                            
//                                 Vehicles[0].lat = This_Vehicle.lat;
//                                 Vehicles[0].lon = This_Vehicle.lon;
//                                 Vehicles[0].alt = This_Vehicle.alt;
//                             }
//                             if (This_Vehicle.nav_bearing) {
//                                printf("\n nav brg, tgt brg, tgt dst = %u/%u/%i \n", This_Vehicle.lat,This_Vehicle.lon,This_Vehicle.alt);
//                              
//                                 Vehicles[0].nav_bearing = This_Vehicle.nav_bearing;
//                                 Vehicles[0].target_bearing = This_Vehicle.target_bearing;
//                                 Vehicles[0].target_distance = This_Vehicle.target_distance;
//                             }
//                             if (This_Vehicle.roll) {
//                              printf("\n roll, pitch, yaw =  %f, %f, %f\n", This_Vehicle.roll,This_Vehicle.pitch,This_Vehicle.yaw);
//                                 
//                                 Vehicles[0].roll = This_Vehicle.roll;
//                                 Vehicles[0].pitch = This_Vehicle.pitch;
//                                 Vehicles[0].yaw = This_Vehicle.yaw;
//                              
                             
                             
//                             }
                            
/**************************************************************************
 *This section is based mxcreatestructarray.c
 * Each field needs its own pointer.  They can be re-used as the for
 * loop cycles as long as they are created inside the for loop each time
 * Re-using fields, or not re-creating them, will crash MATLAB.
 *
 *************************************************************************/
           
    for (i=0; i<NUMBER_OF_VEHICLES; i++) {
        
        mxArray *ptr_updated;
        mxArray *ptr_ID;
        mxArray *ptr_Component_ID;
        mxArray *ptr_type;
        mxArray *ptr_AP_type;
        mxArray *ptr_base_mode;
        mxArray *ptr_custom_mode;
        mxArray *ptr_roll;
        mxArray *ptr_pitch;
        mxArray *ptr_yaw;
        mxArray *ptr_lat;
        mxArray *ptr_lon;
        mxArray *ptr_alt;
        mxArray *ptr_hdg;
        mxArray *ptr_action;
        mxArray *ptr_nav_bearing;
        mxArray *ptr_target_bearing;
        mxArray *ptr_target_distance;
        mxArray *ptr_nav_roll;
        mxArray *ptr_nav_pitch;
        mxArray *ptr_nav_yaw;
        mxArray *ptr_voltage_battery;
        
        
        
        ptr_updated = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_ID = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_Component_ID = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_type = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_AP_type = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_base_mode = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_custom_mode = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_roll = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_pitch = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_yaw = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_lat = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_lon = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_alt = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_hdg = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_action = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_nav_bearing = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_target_bearing = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_target_distance = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_nav_roll = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_nav_pitch = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_nav_yaw = mxCreateDoubleMatrix(1,1,mxREAL);
        ptr_voltage_battery = mxCreateDoubleMatrix(1,1,mxREAL);
        
        
        /*Could also use mxSetField and "field_name" instead of number
         *ByNumber is supposed to be faster.  This is the 'dumb' method, because
         *the program depends on the order not changing.  Example program
         *mccreatestructarray.c used name_field = mxGetFieldNumber(plhs[0],"name")
         *to pull the number for each field.  I've opted not to, but it means
         * if the order changes, it won't work. 
         */
        *mxGetPr(ptr_updated) = Vehicles[i].updated;
        mxSetFieldByNumber(plhs[0],i,0,ptr_updated);
        
        *mxGetPr(ptr_ID) = Vehicles[i].ID;
        mxSetFieldByNumber(plhs[0],i,1,ptr_ID);
        
        *mxGetPr(ptr_Component_ID) = Vehicles[i].Component_ID;
        mxSetFieldByNumber(plhs[0],i,2,ptr_Component_ID);
        
        *mxGetPr(ptr_type) = Vehicles[i].type;
        mxSetFieldByNumber(plhs[0],i,3,ptr_type);
        
        *mxGetPr(ptr_AP_type) = Vehicles[i].AP_type;
        mxSetFieldByNumber(plhs[0],i,4,ptr_AP_type);
        
        *mxGetPr(ptr_base_mode) = Vehicles[i].base_mode;
        mxSetFieldByNumber(plhs[0],i,5,ptr_base_mode);
        
        *mxGetPr(ptr_custom_mode) = Vehicles[i].custom_mode;
        mxSetFieldByNumber(plhs[0],i,6,ptr_custom_mode);
        
        *mxGetPr(ptr_roll) = Vehicles[i].roll;
        mxSetFieldByNumber(plhs[0],i,7,ptr_roll);
        
        *mxGetPr(ptr_pitch) = Vehicles[i].pitch;
        mxSetFieldByNumber(plhs[0],i,8,ptr_pitch);
        
        *mxGetPr(ptr_yaw) = Vehicles[i].yaw;
        mxSetFieldByNumber(plhs[0],i,9,ptr_yaw);
        
        *mxGetPr(ptr_lat) = Vehicles[i].lat;
        mxSetFieldByNumber(plhs[0],i,10,ptr_lat);
        
        *mxGetPr(ptr_lon) = Vehicles[i].lon;
        mxSetFieldByNumber(plhs[0],i,11,ptr_lon);
        
        *mxGetPr(ptr_alt) = Vehicles[i].alt;
        mxSetFieldByNumber(plhs[0],i,12,ptr_alt);
        
        *mxGetPr(ptr_hdg) = Vehicles[i].hdg;
        mxSetFieldByNumber(plhs[0],i,13,ptr_hdg);
        
        *mxGetPr(ptr_action) = Vehicles[i].action;
        mxSetFieldByNumber(plhs[0],i,14,ptr_action);
        
        *mxGetPr(ptr_nav_bearing) = Vehicles[i].nav_bearing;
        mxSetFieldByNumber(plhs[0],i,15,ptr_nav_bearing);
        
        *mxGetPr(ptr_target_bearing) = Vehicles[i].target_bearing;
        mxSetFieldByNumber(plhs[0],i,16,ptr_target_bearing);
        
        *mxGetPr(ptr_target_distance) = Vehicles[i].target_distance;
        mxSetFieldByNumber(plhs[0],i,17,ptr_target_distance);
        
        *mxGetPr(ptr_nav_roll) = Vehicles[i].nav_roll;
        mxSetFieldByNumber(plhs[0],i,18,ptr_nav_roll);
        
        *mxGetPr(ptr_nav_pitch) = Vehicles[i].nav_pitch;
        mxSetFieldByNumber(plhs[0],i,19,ptr_nav_pitch);
        
        *mxGetPr(ptr_nav_yaw) = Vehicles[i].nav_yaw;
        mxSetFieldByNumber(plhs[0],i,20,ptr_nav_yaw);
        
        *mxGetPr(ptr_voltage_battery) = Vehicles[i].voltage_battery;
        mxSetFieldByNumber(plhs[0],i,21,ptr_voltage_battery);
        
    }
    
    
                        } // end if updated
               
               printf(" \n " );
            }
        }
        else{
            printf("invalid syntax\n");
        }
        
    } // end if(nrhs >=1)
} // end mexFunction

  