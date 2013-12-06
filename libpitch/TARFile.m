/*
 * libpitch - An Objective-C interface to libtar
 * Copyright (c) 2013 Michael Dippery <michael@monkey-robot.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "TARFile.h"
#import "NSError+Pitch.h"
#import "Pitch.h"
#import "libtar.h"


@interface TARFile ()
- (TAR *)tarOpen:(NSError **)error;
- (BOOL)tarClose:(TAR *)tar error:(NSError **)error;
@end


@implementation TARFile

+ (TARFile *)fileWithContentsOfFile:(NSString *)source
{
    return [[[self alloc] initWithContentsOfFile:source] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)source
{
    if ((self = [super init])) {
        _source = [source copy];
    }
    return self;
}

- (void)dealloc
{
    [_source release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], [self source]];
}

- (TAR *)tarOpen:(NSError **)error
{
    TAR *tar;
    int success;
    success = tar_open(&tar, (char *) [[self source] UTF8String], NULL, O_RDONLY, 0, 0);
    if (success == -1) {
        if (error) {
            char *e = strerror(errno);
            *error = [NSError TARErrorWithDescription:@"Could not open tarfile" reason:e code:TARFileOpenError];
        }
        return NULL;
    }
    *error = nil;
    return tar;
}

- (BOOL)tarClose:(TAR *)tar error:(NSError **)error
{
    int success = tar_close(tar);
    if (success != 0) {
        if (error) {
            char *e = strerror(errno);
            *error = [NSError TARErrorWithDescription:@"Could not close tarfile" reason:e code:TARFileCloseError];
        }
        return NO;
    }
    *error = nil;
    return YES;
}

- (NSArray *)contents
{
    // TODO: Return an object with full entry, not just name

    NSMutableArray *contents = [NSMutableArray array];
    NSError *error;
    TAR *tar;
    int i;

    tar = [self tarOpen:&error];
    if (!tar) {
        NSLog(@"%@", [error loggingDescription]);
        return nil;
    }

    while ((i = th_read(tar)) == 0) {
        char *path = th_get_pathname(tar);
        NSString *s = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
        [contents addObject:s];
    }

    if (![self tarClose:tar error:&error]) {
        NSLog(@"%@", [error loggingDescription]);
    }

    return [[contents copy] autorelease];
}

- (BOOL)extractToDirectory:(NSString *)directory error:(NSError **)error
{
    TAR *tar;
    int success;

    tar = [self tarOpen:error];
    if (!tar) return NO;

    success = tar_extract_all(tar, (char *) [directory UTF8String]);
    if (success != 0) {
        if (error) {
            char *e = strerror(errno);
            *error = [NSError TARErrorWithDescription:@"Could not extract tar entries" reason:e code:TARFileReadError];
        }
        return NO;
    }

    if (![self tarClose:tar error:error]) return NO;

    *error = nil;
    return YES;
}

@end
