//
//  MWKProgressIndicator.h
//  routemev1
//
//  Created by Max Kölb on 28/03/14.
//  Copyright (c) 2014 Max Kölb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWKProgressIndicator : UIView

+ (void)show;

+ (void)dismiss;
+ (void)dismissWithoutAnimation;

/// Update progress from 0.0 -> 1.0
+ (void)updateProgress:(float)progress;

/// Displays text
+ (void)updateMessage:(NSString *)message;

/// Display an error for 2 seconds
+ (void)showErrorMessage:(NSString *)errorMessage;
+ (void)showSuccessMessage:(NSString *)successMessage;

@end
