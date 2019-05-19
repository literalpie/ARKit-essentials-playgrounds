#  Dragging in SceneKit and ARKit - Playground #

## Overview ##
This project was created to support a Medium blog post that I have not yet published.
The post walks through using gestures to drag items in SceneKit and eventually ARKit. 
The 3 pages of this book correspond to parts 2-5 of the post.

The contents of the medium post may eventually be added as contents of this book, but for now, you should look at the blog post if you need an explanation

## Structure ##
This Xcode project is based on Apple's Playground book template. It includes two things:

- A playground book
- An app for debugging the live view - NOTE: This app has not been tested, and likely doesn't work as-is.

In support of those two things, there are three targets in this Xcode project:

- **PlaygroundBook**: Produces a playground book as its output
- **Book_Sources**: Compiles the book-level auxiliary sources module, allowing book-level sources to be developed with full editor integration
- **LiveViewTestApp**: Produces an app which uses the `Book_Sources` module to show the live view similarly to how it would be shown in Swift Playgrounds

This project includes the PlaygroundSupport and PlaygroundBluetooth frameworks from Swift Playgrounds to allow the Book_Sources and LiveViewTestApp targets to take full advantage of those APIs. The supporting content included with this template, including these frameworks, requires Xcode 10.0 or 10.1 to build. Attempting to use this template with another version of Xcode may result in build errors. I also had problems building with 10.2.

For more information about the playground book file format, see *[Playground Book Format Reference](https://developer.apple.com/library/content/documentation/Xcode/Conceptual/swift_playgrounds_doc_format/)*.
