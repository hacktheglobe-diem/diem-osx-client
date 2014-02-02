//
//  APIClient.h
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

@property (strong, readonly, nonatomic) NSURL *baseURL;

- (id)initWithBaseURL:(NSURL *)URL;

- (void)postOccurrences:(NSArray *)occurrences
                success:(void (^)(void))success
                failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure;

@end
