//
//  NSError+app.h
//
//  Created by Duy Pham
//  Copyright (c) 2015 Duy Pham. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AppError) {
    AppErrorNotImplemented = -99,
    AppErrorSuccessNotError = -1,
    AppErrorUnknown = 00,
    AppErrorInvalidParam = 01,
    AppErrorInvalidResponse = 02,
    AppErrorAPIerror = 03,
    AppErrorFailed = 04, // generic, for all operations
    
    AppErrorNotLoggedIn,
    
    AppErrorBLEInvalidData,
    AppErrorBLEConnectionFail,
    AppErrorBLEConnectionTimedOut,
    AppErrorBLENotRegistered,
    AppErrorBLENotConnected,
    AppErrorBLEoff,
    
    AppErrorBLESyncOneDeviceOnly,
    
    AppErrorUploadSuccess,
    
    AppErrorLoginFail,
    // register
    AppErrorRegisterFirstName,
    AppErrorRegisterLastName,
    AppErrorRegisterEmail,
    AppErrorRegisterEmailInvalid,
    AppErrorRegisterPhoneNumber,
    AppErrorRegisterPhoneNumberInvalid,
    AppErrorRegisterWeight,
    AppErrorRegisterHeight,

    AppErrorRegisterPassword,
    AppErrorRegisterPasswordInvalid,
    AppErrorRegisterConfirmPassword,
    AppErrorRegisterEmailUsed,
    AppErrorSerialNumberInvalid,
    AppErrorRegisterSerialNumberUsed,
    AppErrorSelectDevice,
    AppErrorRegisterAcceptLicense,
};

@interface NSError (app)

+ (instancetype)error:(AppError)error;
- (void)showAlert;

@end
