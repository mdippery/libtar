//
//  TARFile.h
//  LibTar
//
//  Created by Michael Dippery on 12/5/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TARFile : NSObject

@property (readonly) NSString *source;

+ (TARFile *)fileWithContentsOfFile:(NSString *)source;

- (id)initWithContentsOfFile:(NSString *)source;

- (BOOL)extractToDirectory:(NSString *)directory error:(NSError **)error;

@end
