/*******************************************************************************
** File:
**   generic_thruster_msg.h
**
** Purpose:
**  Define GENERIC_THRUSTER application commands and telemetry messages
**
*******************************************************************************/
#ifndef _GENERIC_THRUSTER_MSG_H_
#define _GENERIC_THRUSTER_MSG_H_

#include "cfe.h"


/*
** Ground Command Codes
** TODO: Add additional commands required by the specific component
*/
#define GENERIC_THRUSTER_NOOP_CC                 0
#define GENERIC_THRUSTER_RESET_COUNTERS_CC       1
#define GENERIC_THRUSTER_ENABLE_CC               2
#define GENERIC_THRUSTER_DISABLE_CC              3
#define GENERIC_THRUSTER_TOGGLE_CC               4

/* 
** Telemetry Request Command Codes
** TODO: Add additional commands required by the specific component
*/
#define GENERIC_THRUSTER_REQ_HK_TLM              0
#define GENERIC_THRUSTER_REQ_DATA_TLM            1


/*
** Generic "no arguments" command type definition
*/
typedef struct
{
    /* Every command requires a header used to identify it */
    CFE_MSG_CommandHeader_t CmdHeader;

} GENERIC_THRUSTER_NoArgs_cmd_t;

/*
** GENERIC_THRUSTER write configuration command
*/
typedef struct
{
    CFE_MSG_CommandHeader_t CmdHeader;
    uint32   DeviceCfg;

} GENERIC_THRUSTER_Config_cmd_t;

typedef struct
{
    CFE_MSG_CommandHeader_t CmdHeader;
    uint8                   ThrusterNumber;
    uint8                   State; // 0 = off, 1 = on
    
} GENERIC_THRUSTER_Toggle_cmd_t;

/*
** GENERIC_THRUSTER housekeeping type definition
*/
typedef struct 
{
    CFE_MSG_TelemetryHeader_t TlmHeader;
    uint8   CommandErrorCount;
    uint8   CommandCount;
    uint8   DeviceErrorCount;
    uint8   DeviceCount;
  
    /*
    ** TODO: Edit and add specific telemetry values to this struct
    */
    uint8   DeviceEnabled;

} __attribute__((packed)) GENERIC_THRUSTER_Hk_tlm_t;
#define GENERIC_THRUSTER_HK_TLM_LNGTH sizeof ( GENERIC_THRUSTER_Hk_tlm_t )

#endif /* _GENERIC_THRUSTER_MSG_H_ */
