//
//  BLE_Byte_Offset.h
//  ItsMyLife
//
//  Created by Duy Pham on 6/8/15.
//  Copyright (c) 2015 BHTech. All rights reserved.
//

#ifndef ITSMYLIFE_BLE_BYTE_OFFSET_H
#define ITSMYLIFE_BLE_BYTE_OFFSET_H

// offset meaning for "header"
#define DETAIL_DATA_COMMAND 0
#define DETAIL_DATA_ERROR   1
#define DETAIL_DATA_YEAR    2
#define DETAIL_DATA_MONTH   3
#define DETAIL_DATA_DAY     4
#define DETAIL_DATA_TIME    5
#define DETAIL_DATA_TYPE    6
// offset meaning for active type TYPE == 0x00
#define DETAIL_DATA_CALORIES_L 7
#define DETAIL_DATA_CALORIES_H 8
#define DETAIL_DATA_STEP_L     9
#define DETAIL_DATA_STEP_H     10
#define DETAIL_DATA_DISTANCE_L 11
#define DETAIL_DATA_DISTANCE_H 12
#define DETAIL_DATA_DATA6      13
#define DETAIL_DATA_DATA7      14

// offset meaning for sleep type TYPE == 0xFF
#define DETAIL_DATA_SLEEP0 7
#define DETAIL_DATA_SLEEP1 8
#define DETAIL_DATA_SLEEP2 9
#define DETAIL_DATA_SLEEP3 10
#define DETAIL_DATA_SLEEP4 11
#define DETAIL_DATA_SLEEP5 12
#define DETAIL_DATA_SLEEP6 13
#define DETAIL_DATA_SLEEP7 14

#endif
