//
//  FNDataManager.h
//  FieldNotebook
//
//  Created by Ryan Worl on 3/26/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FNCompletionBlock)(NSArray *objects, NSError* error);

@interface FNDataManager : NSObject

+ (id)sharedManager;

- (void)loadCaseFilesWithBlock:(FNCompletionBlock)block;
- (void)saveCaseFiles:(NSArray *)caseFiles;

- (NSURL *)saveImage:(UIImage *)image;

@end
