//
//  NSError+app.m
//
//  Created by Duy Pham
//  Copyright (c) 2015 Duy Pham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSError+app.h"

static NSString * const AppErrorDomain = @"com.itsmylife24";
static NSString * const AppAlertTitle = @"It's My Life";

@implementation NSError (app)

+ (instancetype)error:(AppError)error {
    return [self errorWithDomain:AppErrorDomain code:error userInfo:@{NSLocalizedDescriptionKey:[self descriptionForError:error]}];
}

+ (NSString *)descriptionForError:(AppError)error {
    // TODO: Localization
    switch (error) {
        case AppErrorNotImplemented:
            return NSLocalizedString(@"Feature not implemented yet.", nil);
        case AppErrorSuccessNotError:
            return NSLocalizedString(@"Success.", nil);
        case AppErrorInvalidParam:
            return NSLocalizedString(@"Invalid parameter.", nil);
        case AppErrorInvalidResponse:
            return NSLocalizedString(@"Invalid response.", nil);
        case AppErrorAPIerror:
            return @"";
        case AppErrorFailed:
            return NSLocalizedString(@"Failed.", nil);
            
        case AppErrorNotLoggedIn:
            return NSLocalizedString(@"Authentication failed. Please log in again.", @"AppErrorNotLoggedIn");
            
        case AppErrorBLEInvalidData:
            return NSLocalizedString(@"Invalid Bluetooth Device data returned.", @"AppErrorBLEInvalidData");
        case AppErrorBLEConnectionFail:
            return NSLocalizedString(@"Bluetooth Device connection failed.", @"AppErrorBLEConnectionFail");
        case AppErrorBLEConnectionTimedOut:
            return NSLocalizedString(@"Bluetooth Device connection timed out.", @"AppErrorBLEConnectionTimedOut");
        case AppErrorBLENotRegistered:
            return NSLocalizedString(@"Wrong device ID. Please connect to your registered device.", @"AppErrorBLENotRegistered");
        case AppErrorBLENotConnected:
            return NSLocalizedString(@"Bluetooth Device is disconnected.", @"AppErrorBLENotConnected");
        case AppErrorBLEoff:
            return NSLocalizedString(@"Bluetooth settings is off.", nil);
            
        case AppErrorBLESyncOneDeviceOnly:
            return NSLocalizedString(@"Data synchronization can only run one device at a time.", @"AppErrorBLESyncOneDeviceOnly");
            
        case AppErrorUploadSuccess:
            return NSLocalizedString(@"Upload completed.", @"AppErrorUploadSuccess");
            
        case AppErrorLoginFail:
            return NSLocalizedString(@"Failed to receive session token.", @"AppErrorLoginFail");
            
        case AppErrorRegisterFirstName:
            return NSLocalizedString(@"First name can not be empty.", nil);
        case AppErrorRegisterLastName:
            return NSLocalizedString(@"Last name can not be empty.", nil);
        case AppErrorRegisterEmail:
            return NSLocalizedString(@"Email can not be empty", nil);
        case AppErrorRegisterEmailInvalid:
            return NSLocalizedString(@"Email is invalid.", nil);
        case AppErrorRegisterPhoneNumber:
            return NSLocalizedString(@"Phone number can not be empty.", nil);
        case AppErrorRegisterPhoneNumberInvalid:
            return NSLocalizedString(@"Phone number is invalid.", nil);
        case AppErrorRegisterWeight:
            return NSLocalizedString(@"Weight is invalid.", nil);
        case AppErrorRegisterHeight:
            return NSLocalizedString(@"Height is invalid.", nil);
            
        case AppErrorRegisterPassword:
            return NSLocalizedString(@"Password can not be empty.", nil);
        case AppErrorRegisterPasswordInvalid:
            return NSLocalizedString(@"Password is invalid.", nil);
        case AppErrorRegisterConfirmPassword:
            return NSLocalizedString(@"Confirm password is not correct.", nil);
        case AppErrorRegisterEmailUsed:
            return NSLocalizedString(@"Email is already registered.", @"AppErrorRegisterEmailUsed");
        case AppErrorSerialNumberInvalid:
            return NSLocalizedString(@"Serial is invalid.", nil);
        case AppErrorRegisterSerialNumberUsed:
            return NSLocalizedString(@"Serial number is already registered.", @"AppErrorRegisterSerialNumberUsed");
        case AppErrorSelectDevice:
            return NSLocalizedString(@"Please select a device", nil);
        case AppErrorRegisterAcceptLicense:
            return NSLocalizedString(@"Confirm have read the Terms and Conditions.", nil);
            
        case AppErrorUnknown:
        default:
            return NSLocalizedString(@"Unknown error.", nil);
    }
}

- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:AppAlertTitle
                                message:[self localizedDescription]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles: nil] show];
}

@end
