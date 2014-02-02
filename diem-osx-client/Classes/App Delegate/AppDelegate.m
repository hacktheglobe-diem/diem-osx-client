//
//  AppDelegate.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "AppDelegate.h"
#import "DiemController.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate () 

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) DiemController *controller;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.controller = [DiemController new];
    [self chooseDiemDirectory];
    
    [self setUpStatusItem];
    
    SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.esben.diem-osx-client", YES);
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

- (void)chooseDiemDirectory
{
    [self.controller checkAndSetupDiemDirectoryCompletion:^(BOOL success)
     {
         if (success) {
             [self.controller startTracking];
         }
         else {
             [[NSApplication sharedApplication] terminate:self];
         }
     }];
}

- (IBAction)quit:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)resetDiemDirectory:(id)sender
{
    [self.controller resetDiemDirectory];
    [self chooseDiemDirectory];
    
}

@end
