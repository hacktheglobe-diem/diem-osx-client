//
//  WatcherEvent.m
//  Tracker
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "WatcherEvent.h"

@implementation WatcherEvent

+ (NSString *)stringFromDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'" allowNaturalLanguage:NO];
    }
    
    return [dateFormatter stringFromDate:date];
}

- (NSDictionary *)serialize
{
    
    return @{
             @"path": self.path,
             @"date": [self.class stringFromDate:self.date],
             @"kind": (self.kind == WatcherEventKindChange ? @"change" : @"unknown")
             };
}

@end
