/*******************************************************************************
** File: sample_device.h
**
** Purpose:
**   This is the header file for the SAMPLE device.
**
*******************************************************************************/
#ifndef _SAMPLE_DEVICE_H_
#define _SAMPLE_DEVICE_H_

/*
** Required header files.
*/
#include "device_cfg.h"
#include "hwlib.h"
#include "generic_thruster_platform_cfg.h"


/*
** Type definitions
** TODO: Make specific to your application
*/
#define GENERIC_THRUSTER_DEVICE_HDR              0xDEAD
#define GENERIC_THRUSTER_DEVICE_HDR_0            0xDE
#define GENERIC_THRUSTER_DEVICE_HDR_1            0xAD

#define GENERIC_THRUSTER_DEVICE_TRAILER          0xBEEF
#define GENERIC_THRUSTER_DEVICE_TRAILER_0        0xBE
#define GENERIC_THRUSTER_DEVICE_TRAILER_1        0xEF

#define GENERIC_THRUSTER_DEVICE_HDR_TRL_LEN      4
#define GENERIC_THRUSTER_DEVICE_CMD_SIZE         6

/*
** GENERIC_THRUSTER device housekeeping telemetry definition
*/
typedef struct
{
    uint8_t   DeviceErrorCount;
    uint8_t   DeviceCount;

} __attribute__((packed)) GENERIC_THRUSTER_Device_HK_tlm_t;
#define GENERIC_THRUSTER_DEVICE_HK_LNGTH sizeof ( GENERIC_THRUSTER_Device_HK_tlm_t )
#define GENERIC_THRUSTER_DEVICE_HK_SIZE GENERIC_THRUSTER_DEVICE_HK_LNGTH + GENERIC_THRUSTER_DEVICE_HDR_TRL_LEN

/*
** Prototypes
*/
int32_t GENERIC_THRUSTER_SetPercentage(uart_info_t *device, uint8_t thruster_number, uint8_t percentage, uint8_t data_length);


#endif /* _GENERIC_THRUSTER_DEVICE_H_ */
