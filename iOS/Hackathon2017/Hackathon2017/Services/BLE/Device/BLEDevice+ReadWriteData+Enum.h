//
//  BLEDevice+ReadWriteData+Enum.h
//  ItsMyLife
//
//  Created by Duy Pham on 2/6/16.
//  Copyright © 2016 BHTech. All rights reserved.
//

#ifndef BLEDevice_ReadWriteData_Enum_h
#define BLEDevice_ReadWriteData_Enum_h

typedef NS_ENUM(UInt8, SEND_DATA_STATUS_tag) {
    DATA_SETTING_TIMER          = 0x01,
    DATA_WRITE_ATTRIBUTE        = 0x02,
    DATA_DELETE_ONEDAY          = 0x04,
    DATA_SET_ID_CODE            = 0x05,
    DATA_READ_ONEDAY            = 0x07,
    DATA_READ_ONEDAY_GOALRATE   = 0x08,
    DATA_START_UPDATE           = 0x09,
    DATA_END_UPDATE             = 0x0A,
    DATA_WRITE_GOAL             = 0x0B,
    DATA_WRITE_ACTIVE_CODE      = 0x0D,
    DATA_WRITE_DISTACE_UNIT     = 0x0F,
    DATA_SETTING_FACTORY        = 0x12,
    DATA_READ_BATTERY           = 0x13,
    DATA_SETTING_BIND           = 0x20,
    DATA_READ_BIND              = 0x21,
    DATA_SETTING_ALARM          = 0x23,
    DATA_READ_ALARM             = 0x24,
    DATA_SETTING_SPORT_TIME     = 0x25,
    DATA_READ_SPORT_TIME        = 0x26,
    DATA_SETTING_WELCOME_STRING = 0x28,
    DATA_READ_WELCOME_STRING    = 0x29,
    DATA_DELETE_WELCOME_STRING  = 0x2A,
    
    
#pragma mark Heart Rate
    DATA_HEART_RATE_MONITOR     = 0x2C,
    
    
    DATA_RESET                  = 0x2E,
    DATA_SHOW_MODEL             = 0x31,
    DATA_SET_TIME               = 0x37,
    DATA_READ_TIMEMODE          = 0x38,
    DATA_SET_DEVICE_NAME        = 0x3D,
    DATA_CURRENT_TIMER          = 0x41,
    DATA_READ_ATTRIBUTE         = 0x42,
    DATA_ONEDAY_DETAIL          = 0x43,
    DATA_ONEDAY_STOREDATA,
    DATA_ONEDAY_HAVEDATA        = 0x46,
    DATA_READ_GOAL              = 0x4B,
    DATA_TELE_ALARM             = 0x4E,
    DATA_READ_DISTACE_UNIT      = 0x4F,
    DATA_ONEDAY_TOATL_DATA1     = 0x5B,
    DATA_ONEDAY_TOATL_DATA2,
    DATA_READ_ECGHISTORYDATA    = 0x96,
    DATA_STOP_ECG               = 0x98,
    DATA_START_ECG              = 0x99,
    DATA_TELE_ALARM_ALT         = 0xCE,
    
    //    DATA_INITIAL,
    //    DATA_READ_WATER,
    //    DATA_READ_UV,
    //    DATA_MCU_RESET,
    //    DATA_DISPLAY_MODE_SETTING,
    //    DATA_DISPLAY_MODE_READ,
    //    DATA_DEVICE_BATTERY_READ,
    //    DATA_SEND_SIMPLE_DATA,
    //    DATA_PASSWORD_BIND,
    //    DATA_OFF,
    
    // Error
    DATA_SETTING_TIMER_ERR        = 0x81,
    DATA_WRITE_ATTRIBUTE_ERR      = 0x82,
    DATA_DELETE_ONEDAY_ERR        = 0x84,
    DATA_SET_ID_CODE_ERR          = 0x85,
    DATA_READ_ONEDAY_ERR          = 0x87,
    DATA_READ_ONEDAY_GOALRATE_ERR = 0x88,
    DATA_START_UPDATE_ERR         = 0x89,
    DATA_END_UPDATE_ERR           = 0x8A,
    DATA_WRITE_GOAL_ERR           = 0x8B,
    DATA_WRITE_ACTIVE_CODE_ERR    = 0x8D,
    DATA_WRITE_DISTACE_UNIT_ERR   = 0x8F,
    DATA_SETTING_FACTORY_ERR      = 0x92,
    DATA_READ_BATTERY_ERR         = 0x93,
    DATA_SETTING_BIND_ERR         = 0xA0,
    DATA_READ_BIND_ERR            = 0xA1,
    DATA_SETTING_ALARM_ERR        = 0xA3,
    DATA_READ_ALARM_ERR           = 0xA4,
    DATA_SETTING_SPORT_TIME_ERR   = 0xA5,
    DATA_READ_SPORT_TIME_ERR      = 0xA6,
    DATA_READ_WELCOME_STRING_ERR  = 0xA9,
    
    
#pragma mark Heart Rate
    DATA_HEART_RATE_MONITOR_ERR   = 0xAC,
    
    
    DATA_RESET_ERR                = 0xAE,
    DATA_SHOW_MODEL_ERR           = 0xB1,
    DATA_SET_TIME_ERR             = 0xB7,
    DATA_READ_TIMEMODE_ERR        = 0xB8,
    DATA_READ_ECGHISTORYDATA_ERR,//A6??
    DATA_STOP_ECG_ERR             = 0xBA,
    DATA_START_ECG_ERR            = 0xBC,
    DATA_SET_DEVICE_NAME_ERR      = 0xBD,
    DATA_CURRENT_TIMER_ERR        = 0xC1,
    DATA_READ_ATTRIBUTE_ERR       = 0xC2,
    DATA_ONEDAY_HAVEDATA_ERR      = 0xC6,
    DATA_READ_GOAL_ERR            = 0xCB,
    DATA_READ_DISTACE_UNIT_ERR    = 0xCF,
    DATA_ONEDAY_DETAIL_ERR        = 0xFF,
};

#endif /* BLEDevice_ReadWriteData_Enum_h */
