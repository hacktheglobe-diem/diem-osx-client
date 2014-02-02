//
//  Watcher.m
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "Watcher.h"
#import <CoreServices/CoreServices.h>
#import "NSString+MD5.h"
#import "WatcherEvent.h"

@interface Watcher ()

@end

@implementation Watcher {
    
    FSEventStreamRef _stream;
    
    FSEventStreamEventId _currentEventId;
}

+ (Watcher *)watcherForURL:(NSURL *)url
              withDelegate:(id<WatcherDelegate>)delegate
          startFromEventId:(FSEventStreamEventId)eventId
{
    NSParameterAssert(url);
    Watcher *newWatcher = [[Watcher alloc] initWithURL:url
                                              delegate:delegate
                                      startFromEventId:eventId];
    if ([newWatcher startStream]) {
        return newWatcher;
    }
    return nil;
}

- (id)initWithURL:(NSURL *)URL
         delegate:(id<WatcherDelegate>)delegate
 startFromEventId:(FSEventStreamEventId)eventId
{
    if (self = [super init])
    {
        _url = URL;
        _delegate = delegate;
        _currentEventId = eventId;
    }
    return self;
}

- (void)dealloc
{
    [self endStream];
}

static void eventCallBack(ConstFSEventStreamRef streamRef,
                   void *clientCallBackInfo,
                   size_t numEvents,
                   void *eventPaths,
                   const FSEventStreamEventFlags eventFlags[],
                   const FSEventStreamEventId eventIds[])
{
    CFArrayRef paths = eventPaths;
    NSArray *events = @[];
    
    for (int i = 0; i < numEvents; i++)
    {
        FSEventStreamEventFlags flag = eventFlags[i];
        
        // TODO: Handle these cases
        // Rescan specified dir
        if (flag & kFSEventStreamEventFlagMustScanSubDirs) {
            
        }
        // Rescan entire dir
        if (flag & (kFSEventStreamEventFlagKernelDropped | kFSEventStreamEventFlagUserDropped))
        {
            
        }
        // Root dir was moved/deleted. Rescan or something?
        if (flag & kFSEventStreamEventFlagRootChanged) {
            
        }
        // Historical events done flag
        if (flag & kFSEventStreamEventFlagHistoryDone) {
            // We should ignore this event.
        }
        
        WatcherEvent *event = [WatcherEvent new];
        event.path = [(__bridge NSArray *)paths objectAtIndex:i];
        event.date = [NSDate date]; // TODO: look up last modified metadata on the actual file
        event.eventId = eventIds[i];
        event.flags = eventFlags[i];
        event.kind = WatcherEventKindChange;
        
        events = [events arrayByAddingObject:event];
    }
    
    [(__bridge Watcher *)clientCallBackInfo callBackWithEvents:events];
}

- (void)callBackWithEvents:(NSArray *)events
{
    // MD5 hashing diem directory path
    for (WatcherEvent *event in events) {
        NSRange diemDirectoryPathRange = [event.path rangeOfString:[_url path]];
        NSString *relativePath = [event.path substringFromIndex:diemDirectoryPathRange.length];
        event.path = [NSString stringWithFormat:@"/%@%@", [[_url path] MD5String], relativePath];
    }
    
    // Sort by eventId
    events = [events sortedArrayWithOptions:0
                            usingComparator:^NSComparisonResult(id obj1, id obj2)
    {
        return [(WatcherEvent *)obj1 eventId] > [(WatcherEvent *)obj2 eventId];
    }];
    
    if ([self.delegate respondsToSelector:@selector(watcher:didRegisterEvents:)])
    {
        [self.delegate watcher:self
             didRegisterEvents:events];
    }
}

- (BOOL)startStream
{
    CFStringRef mypath = (__bridge CFStringRef)[_url path];
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);

    CFAbsoluteTime latency = 1.0; /* Latency in seconds */
    
    FSEventStreamContext streamContext;
    streamContext.version = 0;
    streamContext.info = (__bridge void*)self;
    streamContext.retain = NULL;
    streamContext.release = NULL;
    streamContext.copyDescription = NULL;
    
    /* Create the stream, passing in a callback */
    _stream = FSEventStreamCreate(NULL,
                                  &eventCallBack,
                                  &streamContext,
                                  pathsToWatch,
                                  _currentEventId, /* Or a previous event ID */
                                  latency,
                                  kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents
                                  );
    
    FSEventStreamScheduleWithRunLoop(_stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    if (!FSEventStreamStart(_stream))
    {
        FSEventStreamInvalidate(_stream);
        FSEventStreamRelease(_stream);
        return NO;
    }
    
    return YES;
}

- (void)pauseStream
{
    FSEventStreamStop(_stream);
}

- (void)resumeStream
{
    FSEventStreamStart(_stream);
}

- (FSEventStreamEventId)lastEventIdBeforeDate:(NSDate *)date
{
    dev_t device = FSEventStreamGetDeviceBeingWatched(_stream);
    return FSEventsGetLastEventIdForDeviceBeforeTime(device, [date timeIntervalSince1970]);
}

- (void)endStream
{
    // Flush the stream to process all unhandled events before stopping
    FSEventStreamFlushSync(_stream);
    FSEventStreamStop(_stream);
    FSEventStreamInvalidate(_stream);
    FSEventStreamRelease(_stream);
}

@end
