//
//  WatcherEvent.m
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.a
//

#import "WatcherEvent.h"

@implementation WatcherEvent

+ (NSString *)stringFromDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }
    
    return [dateFormatter stringFromDate:date];
}

- (NSDictionary *)serialize
{
    
    return @{
             @"path": self.path,
             @"time": [self.class stringFromDate:self.date],
             @"kind": (self.kind == WatcherEventKindChange ? @"change" : @"unknown")
             };
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.path forKey:NSStringFromSelector(@selector(path))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeInt32:self.kind forKey:NSStringFromSelector(@selector(kind))];
    [aCoder encodeInt64:self.eventId forKey:NSStringFromSelector(@selector(eventId))];
    [aCoder encodeInt32:self.flags forKey:NSStringFromSelector(@selector(flags))];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(path))];
        self.date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        self.kind = [aDecoder decodeInt32ForKey:NSStringFromSelector(@selector(kind))];
        self.eventId = [aDecoder decodeInt64ForKey:NSStringFromSelector(@selector(eventId))];
        self.flags = [aDecoder decodeInt32ForKey:NSStringFromSelector(@selector(flags))];
    }
    return self;
}

- (BOOL)isHistoryDoneEvent
{
    return (self.flags & kFSEventStreamEventFlagHistoryDone) > 0;
}

- (BOOL)isCreatedEvent {
    return (self.flags & kFSEventStreamEventFlagItemCreated) > 0;
}

- (BOOL)isRemovedEvent {
    return (self.flags & kFSEventStreamEventFlagItemRemoved) > 0;
}

- (BOOL)isInodeMetaModEvent {
    return (self.flags & kFSEventStreamEventFlagItemInodeMetaMod) > 0;
}
- (BOOL)isItemRenamedEvent {
    return (self.flags & kFSEventStreamEventFlagItemRenamed) > 0;
}

- (BOOL)isItemModifiedEvent {
    return (self.flags & kFSEventStreamEventFlagItemModified) > 0;
}

- (BOOL)isFinderInfoModEvent {
    return (self.flags & kFSEventStreamEventFlagItemFinderInfoMod) > 0;
}

- (BOOL)isChangeOwnerEvent {
    return (self.flags & kFSEventStreamEventFlagItemChangeOwner) > 0;
}

- (BOOL)isXattrModEvent {
    return (self.flags & kFSEventStreamEventFlagItemXattrMod) > 0;
}

- (BOOL)isFileEvent {
    return (self.flags & kFSEventStreamEventFlagItemIsFile) > 0;
}

- (BOOL)isDirEvent {
    return (self.flags & kFSEventStreamEventFlagItemIsDir) > 0;
}

- (BOOL)isSymlinkEvent {
    return (self.flags & kFSEventStreamEventFlagItemIsSymlink) > 0;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"EventId: %llu \npath: %@ \ndate: %@ \nisCreatedEvent: %d \nisRemovecEvent: %d \nisInodeMetaModEvent: %d \nisItemRenamedEvent: %d \nisItemModifiedEvent: %d \nisFinderInfoModEvent: %d \nisChangeOwnerEvent: %d \nisXattrModEvent: %d \nisFileEvent: %d \nisDirEvent: %d \nisSymlinkEvent: %d\n",
            self.eventId,
            self.path,
            self.date,
            self.isCreatedEvent,
            self.isRemovedEvent,
            self.isInodeMetaModEvent,
            self.isItemRenamedEvent,
            self.isItemModifiedEvent,
            self.isFinderInfoModEvent,
            self.isChangeOwnerEvent,
            self.isXattrModEvent,
            self.isFileEvent,
            self.isDirEvent,
            self.isSymlinkEvent];
}

/*
 kFSEventStreamEventFlagItemCreated = 0x00000100,
 kFSEventStreamEventFlagItemRemoved = 0x00000200,
 kFSEventStreamEventFlagItemInodeMetaMod = 0x00000400,
 kFSEventStreamEventFlagItemRenamed = 0x00000800,
 kFSEventStreamEventFlagItemModified = 0x00001000,
 kFSEventStreamEventFlagItemFinderInfoMod = 0x00002000,
 kFSEventStreamEventFlagItemChangeOwner = 0x00004000,
 kFSEventStreamEventFlagItemXattrMod = 0x00008000,
 kFSEventStreamEventFlagItemIsFile = 0x00010000,
 kFSEventStreamEventFlagItemIsDir = 0x00020000,
 kFSEventStreamEventFlagItemIsSymlink = 0x00040000,
 */

@end
