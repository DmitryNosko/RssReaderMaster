//
//  RSSURLValidator.h
//  RSSReader
//
//  Created by USER on 8/31/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSURLValidator : NSObject
- (NSURL*) parseFeedResoursecFromURL:(NSURL*) url;
@end
