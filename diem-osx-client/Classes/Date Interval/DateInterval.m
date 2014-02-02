//
//  DateInterval.m
//  diem-osx-client
//
//  Created by Esben Sorig on 02/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "DateInterval.h"

@implementation DateInterval

+ (DateInterval *)dateIntervalWithStartDate:(NSDate *)startDate
                                    endDate:(NSDate *)endDate
{
    NSAssert([startDate compare:endDate] != NSOrderedDescending, @"The startDate must be earlier or equal to the endDate");
    
    return [[DateInterval alloc] initWithStartDate:startDate
                                           endDate:endDate];
}

- (id)initWithStartDate:(NSDate *)startDate
                endDate:(NSDate *)endDate
{
    if (self = [super init]) {
        _startDate = startDate;
        _endDate = endDate;
    }
    return self;
}

- (NSTimeInterval)intervalLength
{
    return [_endDate timeIntervalSinceDate:_startDate];
}

- (NSDate *)midpoint
{
    return [_startDate dateByAddingTimeInterval:[self intervalLength]/2.0];
}

@end
