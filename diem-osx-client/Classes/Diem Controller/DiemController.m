//
//  DiemController.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "DiemController.h"
#import "Watcher.h"
#import "APIClient.h"

NSString* const DiemDirectoryURLKey = @"DiemDirectoryURLKey";

@interface DiemController () <WatcherDelegate>

@property (strong, nonatomic) Watcher *watcher;

@property (strong, nonatomic) APIClient *apiClient;

@end

@implementation DiemController
{
    BOOL _isTracking;
}

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
        [openPanel setLevel:NSFloatingWindowLevel];
        
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
    else {
        // TODO: check if stored URL is still a valid directory
        completion(YES);
    }
}

- (void)resetDiemDirectory
{
    if (_isTracking) {
        [self stopTracking];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DiemDirectoryURLKey];
}

- (NSURL *)diemDirectoryURL
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:DiemDirectoryURLKey];
}

- (void)startTracking
{
    self.watcher = [Watcher watcherForURL:[self diemDirectoryURL]
                             withDelegate:self];
    _isTracking = YES;
}

- (void)stopTracking
{
    self.watcher = nil;
    _isTracking = NO;
}

- (APIClient *)apiClient
{
    if (!_apiClient) {
        _apiClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://localhost:1200/api/"]];
    }
    return _apiClient;
}

#pragma mark - WatcherDelegate

- (void)watcher:(Watcher *)watcher didRegisterEvent:(WatcherEvent *)event
{
    NSLog(@"%@, %llu, %du", event.path, event.eventID, event.flags);
    [self.apiClient postOccurrence:[event serialize] success:^
    {
        NSLog(@"Occurrence posted!");
    } failure:^(NSHTTPURLResponse *response, NSError *error)
    {
        NSLog(@"Occurrence post failed.\n%@\n%@", response, error);
    }];
}

@end
