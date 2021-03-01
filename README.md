# 📁 LSFileWrapper
![Platforms](https://img.shields.io/badge/platform-ios%20%7C%20macos-lightgrey)
[![GitHub](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Swift Package Manager](https://img.shields.io/badge/package%20manager-compatible-brightgreen.svg?logo=data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iNjJweCIgaGVpZ2h0PSI0OXB4IiB2aWV3Qm94PSIwIDAgNjIgNDkiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiAgICA8IS0tIEdlbmVyYXRvcjogU2tldGNoIDYzLjEgKDkyNDUyKSAtIGh0dHBzOi8vc2tldGNoLmNvbSAtLT4KICAgIDx0aXRsZT5Hcm91cDwvdGl0bGU+CiAgICA8ZGVzYz5DcmVhdGVkIHdpdGggU2tldGNoLjwvZGVzYz4KICAgIDxnIGlkPSJQYWdlLTEiIHN0cm9rZT0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIxIiBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPgogICAgICAgIDxnIGlkPSJHcm91cCIgZmlsbC1ydWxlPSJub256ZXJvIj4KICAgICAgICAgICAgPHBvbHlnb24gaWQ9IlBhdGgiIGZpbGw9IiNEQkI1NTEiIHBvaW50cz0iNTEuMzEwMzQ0OCAwIDEwLjY4OTY1NTIgMCAwIDEzLjUxNzI0MTQgMCA0OSA2MiA0OSA2MiAxMy41MTcyNDE0Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDI1IDMxIDI1IDM1IDI1IDM3IDI1IDM3IDE0IDI1IDE0IDI1IDI1Ij48L3BvbHlnb24+CiAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJQYXRoIiBmaWxsPSIjRUZDNzVFIiBwb2ludHM9IjEwLjY4OTY1NTIgMCAwIDE0IDYyIDE0IDUxLjMxMDM0NDggMCI+PC9wb2x5Z29uPgogICAgICAgICAgICA8cG9seWdvbiBpZD0iUmVjdGFuZ2xlIiBmaWxsPSIjRjdFM0FGIiBwb2ludHM9IjI3IDAgMzUgMCAzNyAxNCAyNSAxNCI+PC9wb2x5Z29uPgogICAgICAgIDwvZz4KICAgIDwvZz4KPC9zdmc+)](https://github.com/apple/swift-package-manager)
[![Build iOS](https://github.com/admkopec/LSFileWrapper/workflows/iOS/badge.svg)](https://github.com/admkopec/LSFileWrapper/actions?query=workflow%3A%22iOS%22)
[![Build macOS](https://github.com/admkopec/LSFileWrapper/workflows/macOS/badge.svg)](https://github.com/admkopec/LSFileWrapper/actions?query=workflow%3A%22macOS%22)

Replacement for NSFileWrapper that loads / saves content on-demand. It is specifically designed to handle large packages / bundles or directories with multiple file entries. It requires minimal memory footprint, as it doesn't try to load everything into memory (unlike Apple's NSFileWrapper), but rather tries to memory map the single files only when they're actively being used. This library also has built-in convenience methods for saving / serializing objects like NSData, UIImage, NSImage, NSDictionary, etc...

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
let folderName = directoryWrapper.add(wrapper: LSFileWrapper(directory: ()) withFilename: "Empty Directory Name")

// Adds and overrides any wrappers matching the filename
directoryWrapper.set(wrapper: LSFileWrapper(directory: ()) withFilename: "Empty Directory Name")

// Adds a new text file. Content has to be of Objective-C type, i.e. NSString, NSData... or casted with `as` operator
let filename = directoryWrapper.add(content: NSString("Hello, World!"), withFilename: "hello.txt")

// Adds and overrides any files matching the filename. This method can be used when changes are made to the file
directoryWrapper.set(content: "Hello, World!" as NSString, withFilename: "hello.txt")
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

To update the contents of a regular file wrapper use `-updateContent`, named `update(newContent:)` in Swift.
```objective-c
LSFileWrapper* fileWrapper;

[fileWrapper updateContent: @"Hello, World!"];
```

*Swift:*
```swift
let fileWrapper: LSFileWrapper

fileWrapper.update(newContent: "Hello, World!" as NSString)
```
### Removing wrappers
> **_Notice:_** Directory wrappers only.

To remove a file wrapper from existing wrapper use `-removeFileWrapper` or `removeFileWrapperWithPath`, named `removeWrapper()` or `removeWrapper(with:)` in Swift.
```objective-c
LSFileWrapper* directoryWrapper;

// Using a path, can also contain "/" for subfolder search, all children can be removed
[directoryWrapper removeFileWrapperWithPath: @"hello.txt"];

// Using an instance of a wrapper. Path can also contain "/" for subfolder search, however only 'first' children can be removed.
LSFileWrapper* wrapperToRemove = [directoryWrapper fileWrapperWithPath: @"hello.txt"];
if (wrapperToRemove) {
    [directoryWrapper removeFileWrapper: wrapperToRemove];
}
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

// Using a path, can also contain "/" for subfolder search, all children can be removed
directoryWrapper.removeWrapper(with: "hello.txt")

// Using an instance of a wrapper. Path can also contain "/" for subfolder search, however only 'first' children can be removed.
if let wrapperToRemove = directoryWrapper.wrapper(with: "hello.txt") {
    directoryWrapper.removeWrapper(wrapperToRemove)
}
```
### Getting child wrappers
> **_Notice:_** Directory wrappers only.

To get a wrapper from a directory wrapper call `-fileWrapperWithPath`, named `wrappers(with:)` in Swift, this will also traverse all children based on supplied path.
```objective-c
LSFileWrapper* directoryWrapper;

LSFileWrapper* wrapper = [directoryWrapper fileWrapperWithPath: @"hello.txt"];
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

let wrapper = directoryWrapper.wrapper(with: "hello.txt")
```

To get all first-degree child wrappers from a directory wrapper call `-fileWrappersInPath`, named `wrappers(in:)` in Swift, this will also traverse all children based on supplied path.
```objective-c
LSFileWrapper* directoryWrapper;

NSArray<LSFileWrapper*> *wrappers = [directoryWrapper fileWrappersInPath: @"/"];
```

*Swift:*
```swift
let directoryWrapper: LSFileWrapper

let wrappers = directoryWrapper.wrappers(in: "/")
```
## ⚖️ License
LSFileWrapper is distributed under the [MIT license](LICENSE).
