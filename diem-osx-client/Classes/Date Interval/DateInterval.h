//
//  DateInterval.h
//  diem-osx-client
//
//  Created by Esben Sorig on 02/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateInterval : NSObject

+ (DateInterval *)dateIntervalWithStartDate:(NSDate *)startDate
                                    endDate:(NSDate *)endDate;

@property (strong, readonly, nonatomic) NSDate *startDate;
@property (strong, readonly, nonatomic) NSDate *endDate;

- (NSTimeInterval)intervalLength;

- (NSDate *)midpoint;

@end
