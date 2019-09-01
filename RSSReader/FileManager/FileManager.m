//
//  FileManager.m
//  RSSReader
//
//  Created by Dzmitry Noska on 8/29/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FileManager.h"

@interface FileManager()
@property (strong, nonatomic) NSFileManager* fileManager;
@end

@implementation FileManager

static FileManager* shared;

+(instancetype) shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [FileManager new];
        shared.fileManager = [NSFileManager defaultManager];
    });
    return shared;
}

- (void)save:(FeedItem*) item toFileWithName:(NSString*) fileName {
    
    NSMutableArray* encodedItems = [[NSMutableArray alloc] initWithObjects:[NSKeyedArchiver archivedDataWithRootObject:item], nil];
    
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:encodedItems];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([self.fileManager fileExistsAtPath:filePath]) {
        //load file
        NSMutableArray<FeedItem *>* decodedItems = [self readFile:fileName];
        NSMutableArray<NSData *>* encodedFileContent = [[NSMutableArray alloc] init];
        for (FeedItem* decodedItem in decodedItems) {
            [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:decodedItem]];
        }
        
        [encodedFileContent addObject:[NSKeyedArchiver archivedDataWithRootObject:item]];
        
        NSData* encodedFileData = [NSKeyedArchiver archivedDataWithRootObject:encodedFileContent];
        [encodedFileData writeToFile:filePath atomically:YES];
        
    } else {
        [self.fileManager createFileAtPath:filePath contents:encodedArray attributes:nil];
    }
}

- (NSMutableArray<FeedItem *> *) readFile:(NSString*) fileName { 
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    NSString* filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* fileContent = [fileHandle readDataToEndOfFile];
    
    NSMutableArray<NSData *>* encodedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:fileContent];
    NSMutableArray<FeedItem *>* decodedItems = [[NSMutableArray alloc] init];
    
    for (NSData* data in encodedObjects) {
        FeedItem* item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [decodedItems addObject:item];
    }
    
    return decodedItems;
}

//- (void) saveFeed:(NSMutableArray*) feedData resourceName:(NSString*) resourceName {
//    self.fileManager = [NSFileManager defaultManager];
//
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentDirectory = [paths objectAtIndex:0];
//    NSString* filePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", resourceName]];
//    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:feedData requiringSecureCoding:YES error:nil];
//
//    if ([self.fileManager fileExistsAtPath:filePath]) {
//        //load file
//        NSLog(@"reading file = %@", [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]);
//    } else {
//        //file does not exist
//        [data writeToFile:filePath atomically:YES];
//    }
//}

@end
