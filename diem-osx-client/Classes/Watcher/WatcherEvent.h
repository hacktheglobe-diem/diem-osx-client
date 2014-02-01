//
//  WatcherEvent.h
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WatcherEvent : NSObject

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) unsigned long long eventID;
@property (nonatomic) unsigned int flags;

- (NSDictionary *)serialize;

@end
