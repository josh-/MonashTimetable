[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=phranck&url=https://github.com/phranck/CCNStatusItem&title=CCNStatusItem&tags=github&category=software)
![Travis Status](https://travis-ci.org/phranck/CCNStatusItem.png?branch=master)



## Overview

`CCNStatusItem` is a subclass of `NSObject` to act as a custom `NSStatusItem`. Running on Yosemite it has full support for the class `NSStatusBarButton` which is provided by `NSStatusItem` via the `button` property.

Features:
* Yosemite's dark menu mode will be automatically handled
* Proximity drag detection
* Support for Drag&Drop

It supports a customizable statusItemWindow that will manage any `NSViewController` instance for presenting the content.

This screenshot presents the current example application:

[![CCNStatusItem Example Application](http://share.gifyoutube.com/vpkXD9.gif
)](https://youtu.be/yejBocG9bMc)

## Integration

You can add `CCNStatusItem` by using CocoaPods. Just add this line to your Podfile:

```
pod 'CCNStatusItem'
```


## Usage

After it's integrated into your project you are just a few lines of code away from your (maybe) first `NSStatusItem` with a custom view and a beautiful looking popover window. A good place to add these lines of code is your AppDelegate:

```Objective-C
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
   ...
    [[CCNStatusItem sharedInstance] presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                                         contentViewController:[ContentViewController viewController]];
   ...
}
```

That's all! You will have some options to change the design of this statusItem popover window using `CCNStatusItemWindowConfiguration`. In the example above internally `CCNStatusItem` uses `[CCNStatusItemWindowConfiguration defaultConfiguration]` to set a default design and behavior of the status bar popover window. The next example will show you how to change this design and behaviour:

```Objective-C
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ...
    
    // configure the status item
    CCNStatusItem *sharedItem = [CCNStatusItem sharedInstance];
    sharedItem.windowConfiguration.presentationTransition = CCNPresentationTransitionSlideAndFade;
    sharedItem.proximityDragDetectionHandler = ^(CCNStatusItem *item, NSPoint eventLocation, CCNStatusItemProximityDragStatus dragStatus) {
        switch (dragStatus) {
            case CCNProximityDragStatusEntered:
                [item showStatusItemWindow];
                break;

            case CCNProximityDragStatusExited:
                [item dismissStatusItemWindow];
                break;
        }
    };
    [sharedItem presentStatusItemWithImage:[NSImage imageNamed:@"statusbar-icon"]
                     contentViewController:[ContentViewController viewController]];
    ...
}
```


## Some Side Notes

The statusItem popover's frame size will be determined automatically by calling `preferedContentSize` on the `contentViewController`. So you shouldn't forget to set it to a reasonable value. Using XIB's for building the content a good war to do so is returning:

```Objective-C
- (CGSize)preferredContentSize {
    return self.view.frame.size;
}

```


## Requirements

`CCNStatusItem` was written using ARC and "modern" Objective-C 2. At the moment it has only support for OS X 10.10 Yosemite.


## Contribution

The code is provided as-is, and it is far off being complete or free of bugs. If you like this component feel free to support it. Make changes related to your needs, extend it or just use it in your own project. Pull-Requests and Feedbacks are very welcome. Just contact me at [phranck@cocoanaut.com](mailto:phranck@cocoanaut.com?Subject=[CCNStatusItem] Your component on Github) or send me a ping on Twitter [@TheCocoaNaut](http://twitter.com/TheCocoaNaut). 


## Documentation
The complete documentation you will find on [CocoaDocs](http://cocoadocs.org/docsets/CCNStatusItem/).


## License
This software is published under the [MIT License](http://cocoanaut.mit-license.org).


## Software that uses CCNStatusItem

* [Review Times](http://reviewtimes.cocoanaut.com) - A small Mac tool that shows you the calculated average of the review times for both the Mac App Store and the iOS App Store
* [SalesX](http://salesx.in) - SalesX is the simplest way to reach your iTC sales reports
