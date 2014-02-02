//
//  WatchedEvent.h
//  diem-osx-client
//
//  Created by Esben Sorig on 02/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WatchedEvent : NSManagedObject

@property (nonatomic, retain) NSData * event;
@property (nonatomic, retain) NSNumber * synced;

@end
