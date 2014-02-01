//
//  DiemController.h
//  diem-osx-client
//
//  Created by Esben Sorig on 01/02/2014.
//  Copyright (c) 2014 Esben Sorig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiemController : NSObject

@property (strong, readonly, nonatomic) NSURL *diemDirectoryURL;

- (void)checkAndSetupDiemDirectoryCompletion:(void(^)(BOOL success))completion;
- (void)resetDiemDirectory;
- (void)startTracking;
- (void)stopTracking;

@end
