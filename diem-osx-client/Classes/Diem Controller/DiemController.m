//
//  DiemController.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "DiemController.h"
#import "Watcher.h"

NSString* const DiemDirectoryURLKey = @"DiemDirectoryURLKey";

@interface DiemController () <WatcherDelegate>

@property (strong, nonatomic) Watcher *watcher;

@end

@implementation DiemController

- (void)checkAndSetupDiemDirectoryCompletion:(void (^)(BOOL failed))completion
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
                 [[NSUserDefaults standardUserDefaults] setURL:openPanel.URL
                                                        forKey:DiemDirectoryURLKey];
                 completion(YES);
                 
             }
             else {
                 completion(NO);
             }
         }];
    }
    completion(YES);
}

- (NSURL *)diemDirectoryURL
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:DiemDirectoryURLKey];
}

- (void)startTracking
{
    self.watcher = [Watcher watcherForURL:[self diemDirectoryURL]
                             withDelegate:self];
}

- (void)stopTracking
{
    self.watcher = nil;
}

#pragma mark - WatcherDelegate

- (void)watcher:(Watcher *)watcher didRegisterEvent:(WatcherEvent *)event
{
    
}

@end
