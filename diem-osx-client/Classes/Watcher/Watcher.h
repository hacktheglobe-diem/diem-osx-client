//
//  Watcher.h
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WatcherEvent.h"

@class Watcher;

@protocol WatcherDelegate <NSObject>

- (void)watcher:(Watcher *)watcher didRegisterEvent:(WatcherEvent *)event;

@end

@interface Watcher : NSObject

// Registers for events on the filesystem
+ (Watcher *)watcherForURL:(NSURL *)url
              withDelegate:(id<WatcherDelegate>)delegate;

@property (weak, readonly, nonatomic) id<WatcherDelegate> delegate;
@property (strong, readonly, nonatomic) NSURL *url;

@end
