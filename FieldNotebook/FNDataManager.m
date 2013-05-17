//
//  FNDataManager.m
//  FieldNotebook
//
//  Created by Ryan Worl on 3/26/13.
//  Copyright (c) 2013 Ryan Worl. All rights reserved.
//

#import "FNDataManager.h"


@implementation FNDataManager

+ (id)sharedManager
{
    static FNDataManager *sharedDataManager;
    
    @synchronized(self) {
        if (!sharedDataManager)
            sharedDataManager = [[FNDataManager alloc] init];
        
        return sharedDataManager;
    }
}

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    return basePath;
}

- (NSString *)dataFilePath
{
    NSString* basePath = [self documentsDirectory];

    return [basePath stringByAppendingPathComponent:@"data.plist"];
}

- (void)loadCaseFilesWithBlock:(FNCompletionBlock)block
{
    NSMutableArray* caseFiles = [NSKeyedUnarchiver unarchiveObjectWithFile:[self dataFilePath]];
    if (!caseFiles) {
        caseFiles = @[].mutableCopy;
    }
    
    block(caseFiles, nil);
}

- (void)saveCaseFiles:(NSArray *)caseFiles
{
    [NSKeyedArchiver archiveRootObject:caseFiles toFile:[self dataFilePath]];
}

- (NSString *)createUniqueFilename {
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    
    return uuidStr;
}

- (NSURL *)saveImage:(UIImage *)image
{
    NSString* filename = [[self createUniqueFilename] stringByAppendingPathExtension:@"jpg"];
    NSString* fullPath = [[self documentsDirectory] stringByAppendingPathComponent:filename];
    NSData* imageData = UIImageJPEGRepresentation(image, 0.7);
        
    NSLog(@"filename:%@", fullPath);
    
    NSError* error = nil;
    [imageData writeToFile:fullPath options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    return [NSURL fileURLWithPath:fullPath];
}

@end
