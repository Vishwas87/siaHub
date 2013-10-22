//
//  AppDelegate.h
//  siaHub
//
//  Created by Vincenzo on 22/10/13.
//  Copyright (c) 2013 Vincenzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "login_view.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,login_view_protocol>

@property (strong, nonatomic) UIWindow *window;

@end
