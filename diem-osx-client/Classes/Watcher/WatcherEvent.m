//
//  WatcherEvent.m
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "WatcherEvent.h"

@implementation WatcherEvent

- (NSDictionary *)serialize
{
    return @{
             @"path": self.path,
             @"date": self.date
             };
}

@end
