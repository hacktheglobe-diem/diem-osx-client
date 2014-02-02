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
#import "WatcherEvent.h"
#import "DateInterval.h"

NSString* const DiemDirectoryURLKey = @"DiemDirectoryURLKey";
NSString* const DiemLastEventSynced = @"DiemLastEventSynced";

@interface DiemController () <WatcherDelegate>

@property (strong, nonatomic) Watcher *watcher;

@property (strong, nonatomic) APIClient *apiClient;

@end

@implementation DiemController
{
    BOOL _isTracking;
    BOOL _isHistory;
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:DiemLastEventSynced];
}

- (NSURL *)diemDirectoryURL
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:DiemDirectoryURLKey];
}

- (WatcherEvent *)lastEventSynced
{
    WatcherEvent *lastEventSynced;
    
    NSData *lastEventData = [[NSUserDefaults standardUserDefaults] objectForKey:DiemLastEventSynced];
    if (lastEventData) {
        lastEventSynced = [NSKeyedUnarchiver unarchiveObjectWithData:lastEventData];
    }
    
    return lastEventSynced;
}

- (void)startTracking
{
    _isHistory = YES;
    
    

    self.watcher = [Watcher watcherForURL:[self diemDirectoryURL]
                             withDelegate:self
                         startFromEventId:[[self lastEventSynced] eventId]];
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

- (DateInterval *)estimateDateOfEvent:(WatcherEvent *)event
                       withinInterval:(DateInterval *)interval
                              watcher:(Watcher *)watcher
{
    const NSTimeInterval guessResolution = 30.0;
    
    if ([interval intervalLength] < guessResolution) {
        return interval;
    }
    
    FSEventStreamEventId lastEventIdBeforeMidPoint = [watcher lastEventIdBeforeDate:[interval midpoint]];
    
    if (lastEventIdBeforeMidPoint > event.eventId)
    {
        DateInterval *newInterval = [DateInterval dateIntervalWithStartDate:interval.startDate
                                                                    endDate:[interval midpoint]];
        
        return [self estimateDateOfEvent:event withinInterval:newInterval watcher:watcher];
    }
    else if (lastEventIdBeforeMidPoint < event.eventId)
    {
        DateInterval *newInterval = [DateInterval dateIntervalWithStartDate:[interval midpoint]
                                                                    endDate:interval.endDate];
        
        return [self estimateDateOfEvent:event withinInterval:newInterval watcher:watcher];
    }
    else // (lastEventIdBeforeMidPoint == event.eventId)
    {
        while ([interval intervalLength] > guessResolution)
        {
            if ([watcher lastEventIdBeforeDate:[interval midpoint]] == event.eventId) {
                interval = [DateInterval dateIntervalWithStartDate:interval.startDate
                                                           endDate:interval.midpoint];
            }
            else {
                interval = [DateInterval dateIntervalWithStartDate:interval.midpoint
                                                           endDate:interval.endDate];
            }
        }
        return interval;
    }
}

/*FSEventsGetLastEventIdForDeviceBeforeTime
 
 if not isHistory then we trust the datestamp
 otherwise we need to estimate it
    use the lastEventSynced date as the begin of the unknown interval
        if lastEventSynced does'nt exist we use the date of creation of the root folder
    use the current date as the end of the unknown interval
 
    For each event:
        Guess the date of the event to be in the middle of the interval
        If the lastEvent before our guess is later than the event:
            Set the end of the interval to the guess
        If the lastEvent before our guess is earlier than the event:
            Set the start of the interval to the guess
        Else if the last event before the guess is the event:
            reduce the end of the interval by x amount as long as this condition keeps holding
 
        if the interval is less than 30 seconds:
            Good enough -> update the date of the event
 
 
 */

- (void)guessHistoricalDatesOnEvents:(NSArray *)events watcher:(Watcher *)watcher
{
    // Determine our early reference date
    WatcherEvent *lastEventSynced = [self lastEventSynced];
    NSDate *lastSynced;
    if (lastEventSynced) {
        lastSynced = [lastEventSynced date];
    }
    else {
        // Date of diem folder creation date
        NSURL *diemURL = [self diemDirectoryURL];
        NSDictionary *diemAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[diemURL path] error:nil];
        if (diemAttributes) {
            lastSynced = [diemAttributes objectForKey:NSFileCreationDate];
        }
        else {
            NSLog(@"COULD NOT GET DIEM CREATION DATE!");
            lastSynced = [NSDate dateWithTimeIntervalSince1970:0];
        }
    }
    
    
    for (WatcherEvent *event in events) {
        if ([event isHistoryDoneEvent]) {
            _isHistory = NO;
        }
        
        // If we are getting a historical event: guess
        if (_isHistory) {
            DateInterval *guessInterval = [DateInterval dateIntervalWithStartDate:lastSynced
                                                                          endDate:[NSDate date]];
            guessInterval = [self estimateDateOfEvent:event
                                       withinInterval:guessInterval
                                              watcher:watcher];
            
            event.date = [guessInterval midpoint];
            
            // Update last synced date for consecutive guesses (we can reduce the search interval from our previous search)
            //lastSynced = [guessInterval startDate];   
        }
    }
}

- (void)watcher:(Watcher *)watcher didRegisterEvents:(NSArray *)events
{
    // Let's sync these events with the backend before accepting more events
    [watcher pauseStream];
    
    [self guessHistoricalDatesOnEvents:events watcher:watcher];
    
    NSArray *fileEvents = [events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        WatcherEvent *event = (WatcherEvent *)evaluatedObject;
        
        return event.isFileEvent;
    }]];
    
    if ([fileEvents count] > 0)
    {
        [self postEvents:fileEvents success:^{
            NSLog(@"Occurrences posted!");
            for (WatcherEvent *event in fileEvents) {
                NSLog(@"%@", event);
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[events lastObject]]
                                                      forKey:DiemLastEventSynced];
            if (watcher) {
                [watcher resumeStream];
            }
        }];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[events lastObject]]
                                                  forKey:DiemLastEventSynced];
        
        [watcher resumeStream];
    }
}

- (void)postEvents:(NSArray *)events success:(void(^)(void))success
{
    FSEventStreamEventId latestEvent = 0;
    NSMutableArray *serialized = [@[] mutableCopy];
    for (WatcherEvent *event in events) {
        [serialized addObject:[event serialize]];
        latestEvent = (event.eventId > latestEvent ? event.eventId : latestEvent);
    }
    
    [self.apiClient postOccurrences:serialized
                            success:^
     {
         if (success) success();
         
     } failure:^(NSHTTPURLResponse *response, NSError *error)
     {
         NSLog(@"Occurrences post failed.\n%@\n%@", response, error);
     }];
}



@end
