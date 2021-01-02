# 📁 LSFileWrapper
Replacement for NSFileWrapper that loads / saves content on-demand. Understands how to save / serialize objects like NSData, UIImage, NSImage, NSDictionary, etc...

## 💻 Requirements
LSFileWrapper works on Mac OS X 10.7+ and iOS 8.0 or newer. The Xcode project contains two framework targets for:
* 💻 macOS (10.7 or greater)
* 📱 iOS (8.0 or greater)

## 📖 Usage
* [Creating new wrappers](#creating-new-wrappers)
* [Loading from disk](#loading-from-disk)
* [Writing to disk](#writing-to-disk)
- [Adding contents](#adding-contents)
- [Reading contents](#reading-contents)
- [Updating contents](#updating-contents)
* [Removing wrappers](#removing-wrappers)
* [Getting child wrappers](#getting-child-wrappers)

### Creating new wrappers
To create a new LSFileWrapper use `-initDirectory` for directory wrappers or `-initFile` for regular file wrappers.
These wrappers and all of their contents will be stored entirely in the memory until any of the write methods gets called.

```objective-c
LSFileWrapper* newDirectoryWrapper = [[LSFileWrapper alloc] initDirectory];
LSFileWrapper* newRegularFileWrapper = [[LSFileWrapper alloc] initFile];
```
*Swift:*
```swift
let newDirectoryWrapper = LSFileWrapper(directory: ())
let newRegularFileWrapper = LSFileWrapper(file: ())
```
### Loading from disk
To load an existing wrapper from disk use `-initWithURL`. When boolean `NO` is passed to isDirectory, the init method checks and automatically creates correct LSFileWrapper type based on passed url.

```objective-c
NSURL* url;

LSFileWrapper* existingWrapper = [[LSFileWrapper alloc] initWithURL: url isDirectory: NO];
```

*Swift:*
```swift
let url: URL

let existingWrapper = LSFileWrapper(with: url, isDirectory: false)
```
### Writing to disk
> **_Notice:_** Writing methods should only be called on the top most wrapper – a wrapper that has no parents.

To write the wrapper to disk call `-writeToURL` or `-writeUpdatesToURL`, the difference between the two being that updates will update the cached wrapper location and remove changes from memory, so use this only in situations like autosave. For duplicate operations use `-writeToURL`. Only the main wrapper can be written to disk – the wrapper that has no parents. If the write is issued as part of NSDocument's save routine there's a convenience method `-writeToURL forSaveOperation` that automatically calls `-writeToURL` or `-writeUpdatesToURL` based on save operation and also handles document backups (versioning) and url switches on save as.
```objective-c
LSFileWrapper* mainWrapper;
NSURL* url;

// Saves all contents to disk at specified URL
[mainWrapper writeToURL: url];

// Dumps all changes to the specified URL, make sure that the LSFileWrapper contents are present at the URL, 
// otherwise the write method could result in partial contents on the disk and potential loss of data.
[mainWrapper writeUpdatesToURL: url];
```
*NSDocument (macOS only):*
```objective-c
LSFileWrapper* mainWrapper;

-(BOOL)writeToURL:(NSURL *)url forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError __autoreleasing *)outError {
    [url startAccessingSecurityScopedResource]; // Recommended on OS X 10.7.3 and newer
    BOOL success = [mainWrapper writeToURL: url forSaveOperation: saveOperation originalContentsURL: absoluteOriginalContentsURL backupDocumnetURL: [self backupFileURL] outError: outError];
    [url stopAccessingSecurityScopedResource];
    return success;
}
```

*Swift:*
```swift
let mainWrapper: LSFileWrapper
let url: URL

// Saves all contents to disk at specified URL
mainWrapper.write(to: url)

// Dumps all changes to the specified URL, make sure that the LSFileWrapper contents are present at the URL, 
// otherwise the write method could result in partial contents on the disk and potential loss of data.
mainWrapper.writeUpdates(to: url)
```

*NSDocument (macOS only):*
```swift
let mainWrapper: LSFileWrapper

override func write(to url: URL, for saveOperation: SaveOperationType, originalContentsURL absoluteOriginalContentsURL: URL?) throws {
    _ = url.startAccessingSecurityScopedResource()
    try mainPackageWrapper.write(to: url, for: saveOperation, originalContentsURL: absoluteOriginalContentsURL, backupDocumentURL: self.backupFileURL)
    url.stopAccessingSecurityScopedResource()
}
```
### Adding contents
> **_Notice:_** Directory wrappers only.

To add a file wrapper to an existing directory wrapper use `-addFileWrapper` or `-setFileWrapper`, the difference between the two being that *add* will suffix a filename with 2, 3, 4, etc… if the wrapper with the same name already exists and return the final filename, *set* will overwrite any existing file wrappers. 
`-addContent` and `-setContent` work the same way, but create the file wrapper for you.
```objective-c
LSFileWrapper* directoryWrapper;

// Adds an empty directory with preferred name
NSString* folderName = [directoryWrapper addFileWrapper: [[LSFileWrapper alloc] initDirectory] withFilename: @"Empty Directory Name"];

// Adds and overrides any wrappers matching the filename
[directoryWrapper setFileWrapper: [[LSFileWrapper alloc] initDirectory] withFilename: @"Empty Directory Name"];

// Adds a new text file
NSString* fileName = [directoryWrapper addContent: @"Hello, World!" withFilename: @"hello.txt"];

// Adds and overrides any files matching the filename. This method could also be used when changes are made to the file
[directoryWrapper setContent: @"Hello, World!" withFilename: @"hello.txt"];
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

// Adds an empty directory with preferred name
let folderName = directoryWrapper.addFileWrapper(LSFileWrapper(directory: ()) withFilename: "Empty Directory Name")

// Adds and overrides any wrappers matching the filename
directoryWrapper.setFileWrapper(LSFileWrapper(directory: ()) withFilename: "Empty Directory Name")

// Adds a new text file. Content has to be of Objective-C type, i.e. NSString, NSData... or casted with `as` operator
let filename = directoryWrapper.addContent(NSString("Hello, World!"), withFilename: "hello.txt")

// Adds and overrides any files matching the filename. This method can be used when changes are made to the file
directoryWrapper.setContent("Hello, World!" as NSString, withFilename: "hello.txt")
```
### Reading Contents
> **_Notice:_** File wrappers only.

To retrieve contents of a regular file wrapper use one of various convenience methods: `-data`, `-string`, `-dictionary`, `-image`.
```objective-c
LSFileWrapper* fileWrapper;

NSData* data = [fileWrapper data];
NSString* string = [fileWrapper string];
```

*Swift:*
```swift
let fileWrapper: LSFileWrapper

let optionalData = fileWrapper.data()
let optionalString = fileWrapper.string()
```
### Updating Contents
> **_Notice:_** File wrappers only.

To update the contents of a regular file wrapper use `-updateContent`.
```objective-c
LSFileWrapper* fileWrapper;

[fileWrapper updateContent: @"Hello, World!"];
```

*Swift:*
```swift
let fileWrapper: LSFileWrapper

fileWrapper.updateContent("Hello, World!" as NSString)
```
### Removing wrappers
> **_Notice:_** Directory wrappers only.

To remove a file wrapper from existing wrapper use `-removeFileWrapper`.
```objective-c
LSFileWrapper* directoryWrapper;

// Using a filename, only 'first' children can be removed
[directoryWrapper removeFileWrapperWithFilename: @"hello.txt"];

// Using an instance of a wrapper. Path can also contain "/" for subfolder search, however only 'first' children can be removed.
LSFileWrapper* wrapperToRemove = [directoryWrapper fileWrapperWithPath: @"hello.txt"];
if (wrapperToRemove) {
    [directoryWrapper removeFileWrapper: wrapperToRemove];
}
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

// Using a filename, only 'first' children can be removed
directoryWrapper.removeFileWrapper(with: "hello.txt")

// Using an instance of a wrapper. Path can also contain "/" for subfolder search, however only 'first' children can be removed.
if let wrapperToRemove = directoryWrapper.withPath("hello.txt") {
    directoryWrapper.removeFileWrapper(wrapperToRemove)
}
```
### Getting child wrappers
> **_Notice:_** Directory wrappers only.

To get wrappers from a directory wrapper use `@property fileWrappers` or call `-fileWrapperWithPath`, the latter will also traverse all children based on path.
```objective-c
LSFileWrapper* directoryWrapper;

LSFileWrapper* wrapper = [directoryWrapper fileWrapperWithPath: @"hello.txt"];
LSFileWrapper* wrapper = [directoryWrapper [fileWrappers objectForKey: @"hello.txt"]];
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

let wrapper = directoryWrapper.withPath("hello.txt")
let wrapper = directoryWrapper.fileWrappers?["hello.txt"]
```
