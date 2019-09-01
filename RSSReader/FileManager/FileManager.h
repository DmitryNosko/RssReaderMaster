//
//  FileManager.h
//  RSSReader
//
//  Created by Dzmitry Noska on 8/29/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedItem.h"

@interface FileManager : NSObject
+(instancetype) shared;
- (void)save:(FeedItem*) item toFileWithName:(NSString*) fileName;
- (NSMutableArray<FeedItem *> *) readFile:(NSString*) fileName;
@end

