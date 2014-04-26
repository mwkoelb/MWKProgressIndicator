//
//  MWKProgressIndicator.m
//  routemev1
//
//  Created by Max Kölb on 28/03/14.
//  Copyright (c) 2014 Max Kölb. All rights reserved.
//

#import "MWKProgressIndicator.h"

#import <AVFoundation/AVFoundation.h>

#define MWKProgressIndicatorHeight 64.0f

@implementation MWKProgressIndicator
{
    float _progress;
    UIView *_progressTrack;
    
    UILabel *_titleLabel;
    
    BOOL _lock;
}

+ (instancetype)sharedIndicator
{
    static MWKProgressIndicator *indicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^
                  {
                      indicator = [MWKProgressIndicator new];
                  });
    return indicator;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, -MWKProgressIndicatorHeight, [UIScreen mainScreen].bounds.size.width, MWKProgressIndicatorHeight);
    [[[[[UIApplication sharedApplication] keyWindow] subviews] firstObject] addSubview:self];
    
    _progress = 0.0;
    _progressTrack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.bounds.size.height)];
    [_progressTrack setBackgroundColor:[UIColor colorWithRed:0.53 green:0.82 blue:1 alpha:1]];
    [self addSubview:_progressTrack];
    
    float statusBarHeight = 14.0f;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, statusBarHeight, self.bounds.size.width, MWKProgressIndicatorHeight - statusBarHeight)];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20]];
    [_titleLabel setText:@"Loading..."];
    [self addSubview:_titleLabel];
    
    _lock = NO;
    
    return self;
}

+ (void)show
{
    MWKProgressIndicator *indicator = [MWKProgressIndicator sharedIndicator];
    if (CGRectGetMinY(indicator.frame) == 0.0) return;
    [indicator setTopLocationValue:0];
}

+ (void)dismiss
{
    MWKProgressIndicator *indicator = [MWKProgressIndicator sharedIndicator];
    [indicator dismissAnimated:YES];
}

+ (void)dismissWithoutAnimation
{
    MWKProgressIndicator *indicator = [MWKProgressIndicator sharedIndicator];
    [indicator dismissAnimated:NO];
}

- (void)dismissAnimated:(BOOL)animated
{
    if (CGRectGetMinY(self.frame) == -MWKProgressIndicatorHeight) return;
    
    if (animated)
    {
        [self updateProgress:0.0];
        [self setTopLocationValue:-MWKProgressIndicatorHeight];
    }
    else
    {
        _progressTrack.frame = CGRectMake(0, 0, 0, self.frame.size.height);
        [self setTopLocationValue:-MWKProgressIndicatorHeight withDuration:0.0];
    }
}

- (void)setTopLocationValue:(float)value
{
    [self setTopLocationValue:value withDuration:0.4];
}

- (void)setTopLocationValue:(float)value withDuration:(float)duration
{
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         [self setFrame:CGRectMake(0, value, self.bounds.size.width, self.bounds.size.height)];
     }
                     completion:nil];
}

+ (void)updateProgress:(float)progress
{
    MWKProgressIndicator *indicator = [MWKProgressIndicator sharedIndicator];
    [indicator updateProgress:progress];
}

- (void)updateProgress:(float)progress
{
    if (0.0f <= progress && progress < 1.1f)
    {
        float units = self.frame.size.width / 1;
        _progress = progress;
        
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^
         {
             _progressTrack.frame = CGRectMake(0, 0, units * progress, self.bounds.size.height);
         }
                         completion:nil];
    }
}

+ (void)updateMessage:(NSString *)message
{
    [MWKProgressIndicator updateMessage:message type:MWKProgressMessageUpdateTypeText];
}

+ (void)updateMessage:(NSString *)message type:(MWKProgressMessageUpdateType)type
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (type == MWKProgressMessageUpdateTypeAll || type == MWKProgressMessageUpdateTypeText)
                       {
                           MWKProgressIndicator *indicator = [MWKProgressIndicator sharedIndicator];
                           [indicator updateMessage:message];
                       }
                       
                       if (type == MWKProgressMessageUpdateTypeAll || type == MWKProgressMessageUpdateTypeVoice)
                       {
                           [MWKProgressIndicator speakMessage:message];
                       }
                   });
}


- (void)updateMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       _titleLabel.text = message;
                   });
}

+ (void)showErrorMessage:(NSString *)errorMessage
{
    [[MWKProgressIndicator sharedIndicator] showWithColor:[UIColor redColor] duration:2 message:errorMessage];
}

+ (void)showSuccessMessage:(NSString *)successMessage
{
    [[MWKProgressIndicator sharedIndicator] showWithColor:[UIColor greenColor] duration:2 message:successMessage];
}

+ (void)showColor:(UIColor *)color duration:(float)duration message:(NSString *)message
{
    [[MWKProgressIndicator sharedIndicator] showWithColor:color duration:duration message:message];
}

+ (void)showMessage:(NSString *)message color: (UIColor *)color
{
    [[MWKProgressIndicator sharedIndicator] showWithColor:color message:message];
}

- (void)showWithColor:(UIColor *)color duration:(float)duration message:(NSString *)message
{
    if (_lock) return;
    
    _lock = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        float hideDuration = 0.5;
        
        [self setTopLocationValue:-MWKProgressIndicatorHeight withDuration:hideDuration];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(hideDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [self updateProgress:0.0];
                           
                           [self setTopLocationValue:0 withDuration:hideDuration];
                           self.backgroundColor = color;
                           [self updateMessage:message];
                       });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration+hideDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(),^
                       {
                           
                           [self setTopLocationValue:-MWKProgressIndicatorHeight withDuration:hideDuration];
                           
                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(hideDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                          {
                                              
                                              self.backgroundColor = [UIColor whiteColor];
                                              _lock = NO;
                                          });
                       });
    });
}

- (void)showWithColor:(UIColor *)color message:(NSString *)message
{
  [self updateProgress:0.0];
  [self setTopLocationValue:0];
  self.backgroundColor = color;
  [self updateMessage:message];
}

+ (void)setTrackColor:(UIColor *)color
{
    [[MWKProgressIndicator sharedIndicator] updateTrackColor:color];
}

- (void)updateTrackColor:(UIColor *)color
{
    _progressTrack.backgroundColor = color;
}

+ (void)speakMessage:(NSString *)message
{
    static AVSpeechSynthesizer *synthesizer = nil;
    
    if (!synthesizer)
    {
        synthesizer = [AVSpeechSynthesizer new];
    }
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:message];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    utterance.rate = 0.3;
    
    [synthesizer speakUtterance:utterance];
}

@end
