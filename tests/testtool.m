#import <Foundation/Foundation.h>
#import "Pitch.h"


int main(int argc, const char **argv)
{
    char cwd[MAXPATHLEN+1];
    getcwd(cwd, MAXPATHLEN);
    printf("cwd:     %s\n", cwd);
    printf("argv[1]: %s\n", argv[1]);
    return 0;
}
