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

@interface Watcher ()

@end

@implementation Watcher {
    
    FSEventStreamRef _stream;
    
}

+ (Watcher *)watcherForURL:(NSURL *)url
              withDelegate:(id<WatcherDelegate>)delegate
{
    NSParameterAssert(url);
    Watcher *newWatcher = [[Watcher alloc] initWithURL:url
                                           andDelegate:delegate];
    if ([newWatcher startStream]) {
        return newWatcher;
    }
    return nil;
}

- (id)initWithURL:(NSURL *)URL
      andDelegate:(id<WatcherDelegate>)delegate
{
    if (self = [super init])
    {
        _url = URL;
        _delegate = delegate;
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
        
        WatcherEvent *event = [WatcherEvent new];
        event.path = [(__bridge NSArray *)paths objectAtIndex:i];
        event.date = [NSDate date]; // TODO: look up last modified metadata on the actual file
        event.eventID = eventIds[i];
        event.flags = eventFlags[i];
        event.kind = WatcherEventKindChange;
        
        [(__bridge Watcher *)clientCallBackInfo callBackWithEvent:(WatcherEvent *)event];
    }
}

- (void)callBackWithEvent:(WatcherEvent *)event
{
    // MD5 hashing diem directory path
    NSRange diemDirectoryPathRange = [event.path rangeOfString:[_url path]];
    NSString *relativePath = [event.path substringFromIndex:diemDirectoryPathRange.length];
    event.path = [NSString stringWithFormat:@"/%@%@", [[_url path] MD5String], relativePath];
    
    if ([self.delegate respondsToSelector:@selector(watcher:didRegisterEvent:)])
    {
        [self.delegate watcher:self
              didRegisterEvent:event];
    }
}

- (BOOL)startStream
{
    CFStringRef mypath = (__bridge CFStringRef)[_url path];
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&mypath, 1, NULL);

    CFAbsoluteTime latency = 0.0; /* Latency in seconds */
    
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
                                  kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
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

- (void)endStream
{
    // Flush the stream to process all unhandled events before stopping
    FSEventStreamFlushSync(_stream);
    FSEventStreamStop(_stream);
    FSEventStreamInvalidate(_stream);
    FSEventStreamRelease(_stream);
}

@end
