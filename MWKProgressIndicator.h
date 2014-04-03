//
//  MWKProgressIndicator.h
//  routemev1
//
//  Created by Max Kölb on 28/03/14.
//  Copyright (c) 2014 Max Kölb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MWKProgressMessageUpdateType)
{
    MWKProgressMessageUpdateTypeText,
    MWKProgressMessageUpdateTypeVoice,
    MWKProgressMessageUpdateTypeAll
};

@interface MWKProgressIndicator : UIView

+ (void)show;

+ (void)dismiss;
+ (void)dismissWithoutAnimation;

/// Update progress from 0.0 -> 1.0
+ (void)updateProgress:(float)progress;

/// Updates message
+ (void)updateMessage:(NSString *)message;

/// Updates a combination of voice or text, determined by updatetype
+ (void)updateMessage:(NSString *)message type:(MWKProgressMessageUpdateType)type;

/// Display an error for 2 seconds
+ (void)showErrorMessage:(NSString *)errorMessage;

/// Display success for 2 seconds
+ (void)showSuccessMessage:(NSString *)successMessage;

/// Convenience message for speaking
+ (void)speakMessage:(NSString *)message;

@end
