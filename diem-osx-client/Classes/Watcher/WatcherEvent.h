//
//  WatcherEvent.h
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WatcherEventKindChange
} WatcherEventKind;

@interface WatcherEvent : NSObject <NSCoding>

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) WatcherEventKind kind;
@property (nonatomic) FSEventStreamEventId eventId;
@property (nonatomic) FSEventStreamEventFlags flags;

- (NSDictionary *)serialize;


// Event specifics
- (BOOL)isHistoryDoneEvent;

- (BOOL)isCreatedEvent;
- (BOOL)isRemovedEvent;
- (BOOL)isInodeMetaModEvent;
- (BOOL)isItemRenamedEvent;
- (BOOL)isItemModifiedEvent;
- (BOOL)isFinderInfoModEvent;
- (BOOL)isChangeOwnerEvent;
- (BOOL)isXattrModEvent;
- (BOOL)isFileEvent;
- (BOOL)isDirEvent;
- (BOOL)isSymlinkEvent;

@end
