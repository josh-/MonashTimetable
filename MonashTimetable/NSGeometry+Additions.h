//
//  NSGeometry+Additions.h
//  MonashTimetable
//
//  Created by Josh Parnham on 27/07/2015.
//  Copyright (c) 2015 Josh Parnham. All rights reserved.
//

NS_INLINE NSPoint NSPointFromRect(NSRect aRect) {
    return NSMakePoint(aRect.origin.x, aRect.origin.y);
}

NS_INLINE NSRect NSRectFromPoint(NSPoint aPoint) {
    return NSMakeRect(aPoint.x, aPoint.y, 0, 0);
}
