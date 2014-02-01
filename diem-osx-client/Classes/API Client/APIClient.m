//
//  APIClient.m
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import "APIClient.h"
#import <AFNetworking/AFNetworking.h>

@interface APIClient ()

@property (strong, readonly, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation APIClient

- (id)initWithBaseURL:(NSURL *)baseURL
{
    if ((self = [super init]))
    {
        _baseURL = baseURL;
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:_baseURL];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)postOccurrence:(NSDictionary *)occurence
               success:(void (^)(void))success
               failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure
{
    [_manager POST:@"occurrences"
        parameters:occurence
           success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (success) success();
    }      failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (failure) failure(operation.response, error);
    }];
}


@end
