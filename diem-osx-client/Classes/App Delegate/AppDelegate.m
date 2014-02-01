//
//  AppDelegate.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "AppDelegate.h"
#import "DiemController.h"

@interface AppDelegate () 

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) DiemController *controller;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.controller = [DiemController new];
    [self.controller checkAndSetupDiemDirectoryCompletion:^(BOOL success)
    {
        if (success) {
            [self.controller startTracking];
        }
        else {
            [[NSApplication sharedApplication] terminate:self];
        }
    }];
    
    [self setUpStatusItem];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.controller stopTracking];
}

#pragma mark - Custom methods

- (void)setUpStatusItem
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusItem.title = @"Diem";
    
    self.statusItem.menu = self.menu;
    self.statusItem.highlightMode = YES;
}

@end
