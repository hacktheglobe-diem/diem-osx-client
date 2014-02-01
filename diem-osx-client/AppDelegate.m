//
//  AppDelegate.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "AppDelegate.h"

NSString* const DiemDirectoryURLKey = @"DiemDirectoryURLKey";

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkAndSetupDiemDirectory];
    
    [self setUpStatusItem];
}

- (void)checkAndSetupDiemDirectory
{
    if (![[NSUserDefaults standardUserDefaults] URLForKey:DiemDirectoryURLKey])
    {
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        openPanel.canChooseFiles = NO;
        openPanel.canChooseDirectories = YES;
        openPanel.allowsMultipleSelection = NO;
        openPanel.directoryURL = [NSURL URLWithString:@"~/"];
        openPanel.canCreateDirectories = YES;
        
        [openPanel beginWithCompletionHandler:^(NSInteger result)
         {
             if (result == NSFileHandlingPanelOKButton)
             {
                 [[NSUserDefaults standardUserDefaults] setURL:openPanel.URL forKey:DiemDirectoryURLKey];
             }
             else {
                 [[NSApplication sharedApplication] terminate:self];
             }
         }];
    }
    
    self.diemDirectoryURL = [[NSUserDefaults standardUserDefaults] URLForKey:DiemDirectoryURLKey];
}

- (void)setUpStatusItem
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    self.statusItem.title = @"Diem";
    
    self.statusItem.menu = self.menu;
    self.statusItem.highlightMode = YES;
}

@end
