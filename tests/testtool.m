#import <Foundation/Foundation.h>
#import "Pitch.h"


int main(int argc, const char **argv)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *path = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    fprintf(stderr, "Opening path: %s\n", [path UTF8String]);
    TARFile *tar = [TARFile fileWithContentsOfFile:path];
    fprintf(stderr, "Created TARFile: %s\n", [[tar description] UTF8String]);
    [tar extractToDirectory:@"/tmp" error:NULL];

    [pool release];
    return 0;
}
