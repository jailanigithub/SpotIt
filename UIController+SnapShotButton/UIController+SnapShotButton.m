//
//  UIController+SnapShotButton.m
//  CommonConfirmation
//
//  Created by Mani on 4/4/14.
//
//

#import "UIController+SnapShotButton.h"
#import "ScreenShotControl.h"
#import <objc/runtime.h>

@implementation UIViewController (SnapShotButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(snapControlViewDidAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

- (void)snapControlViewDidAppear:(BOOL)animated {
    [self snapControlViewDidAppear:animated];
    [[ScreenShotControl sharedHandler] removeFromSuperview];
    [self.view.window insertSubview:[ScreenShotControl sharedHandler] aboveSubview:self.view];
}

@end
