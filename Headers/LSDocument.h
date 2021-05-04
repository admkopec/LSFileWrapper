//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Distributed under MIT license
//

#import <TargetConditionals.h>
#if !TARGET_OS_OSX
#import <UIKit/UIKit.h>

@class LSFileWrapper;

@interface LSDocument : UIDocument

- (void)saveWithCompletionHandler:(void (^)(BOOL success))completionHandler;

- (BOOL)writePathFirst:(LSFileWrapper *)path
     andAttributes:(NSDictionary *)additionalFileAttributes
       safelyToURL:(NSURL *)url
  forSaveOperation:(UIDocumentSaveOperation)saveOperation
             error:(NSError *__autoreleasing *)outError;
- (void)savePathFirst:(NSString *)path
     firstHandler:(void (^)(BOOL success))firstHandler
completionHandler:(void (^)(BOOL success))completionHandler;

@end
#endif
