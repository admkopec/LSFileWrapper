//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Distributed under MIT license
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LSFileWrapper : NSObject

- (id)initFile;
- (id)initDirectory;
- (id)initWithURL:(NSURL *)url isDirectory:(BOOL)isDir;

- (void)loadCache;

- (NSData *)data;
- (NSString *)string;
- (NSDictionary *)dictionary;
- (UIImage *)image;

- (void)updateContent:(id<NSObject>)content;
- (void)deleteContent;

- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path;
- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path create:(BOOL)create isDirectory:(BOOL)isDir;

- (NSString *)addFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;
- (void)setFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;
- (NSString *)addContent:(id<NSObject>)content_ withFilename:(NSString *)filename;
- (void)setContent:(id<NSObject>)content_ withFilename:(NSString *)filename;

- (BOOL)writeUpdatesToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;

@property (readonly, strong, nonatomic) NSString *filename;
@property (readonly, strong, nonatomic) NSString *fileType;
@property (readonly, nonatomic) BOOL updated;
@property (readonly, nonatomic) BOOL isDirectory;
@property (assign, nonatomic) BOOL cacheFile;
@end
