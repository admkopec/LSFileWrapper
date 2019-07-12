//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Distributed under MIT license
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

//! Project version number for LSFileWrapper.
FOUNDATION_EXPORT double LSFileWrapperVersionNumber;

//! Project version string for LSFileWrapper.
FOUNDATION_EXPORT const unsigned char LSFileWrapperVersionString[];

@interface LSFileWrapper : NSObject

- (id)initFile;
- (id)initDirectory;
- (id)initWithURL:(NSURL *)url isDirectory:(BOOL)isDir;

- (NSData *)data;
- (NSString *)string;
- (NSDictionary *)dictionary;
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
- (UIImage *)image;
#else
- (NSImage *)image;
#endif

- (void)updateContent:(id<NSObject>)content;
- (void)deleteContent;

- (void)incReserve;
- (void)decReserve;
- (void)deleteUnreserved;

- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path;
- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path create:(BOOL)create isDirectory:(BOOL)isDir;

- (NSString *)addFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;
- (void)setFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;
- (void)removeFileWrapper:(LSFileWrapper *)fileWrapper;
- (NSString *)addContent:(id<NSObject>)content_ withFilename:(NSString *)filename;
- (void)setContent:(id<NSObject>)content_ withFilename:(NSString *)filename;

- (BOOL)writeUpdatesToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;
- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;

@property (readonly, strong, nonatomic) NSString *filename;
@property (readonly, strong, nonatomic) NSString *fileType;
@property (readonly, nonatomic) BOOL updated;
@property (readonly, nonatomic) BOOL isDirectory;
@property (assign, nonatomic) NSInteger reserve;
@end

@interface LSFileWrapper ()
@property (weak, nonatomic) LSFileWrapper *parent;
@property (strong, nonatomic) NSMutableDictionary<NSString*, LSFileWrapper*> *fileWrappers;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSURL *writtenURL;
@property (strong, nonatomic) id<NSObject> content;
@property (assign, nonatomic) BOOL updated;
@property (assign, nonatomic) BOOL deleted;
@property (assign, nonatomic) BOOL cacheFile;
@end
