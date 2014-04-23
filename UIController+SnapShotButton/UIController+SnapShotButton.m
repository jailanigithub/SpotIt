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
        SEL addSwizzledSelector = @selector(snapControllerViewDidAppearAdd:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method addSwizzledMethod = class_getInstanceMethod(class, addSwizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(addSwizzledMethod),
                        method_getTypeEncoding(addSwizzledMethod));
        if (!didAddMethod)
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling
-(void)snapControllerViewDidAppearAdd:(BOOL)animated
{
    [[ScreenShotControl sharedHandler] removeFromSuperview];
    [self.view.window insertSubview:[ScreenShotControl sharedHandler] aboveSubview:self.view];
}

- (void)snapControlViewDidAppear:(BOOL)animated {
    [self snapControlViewDidAppear:animated];
    [[ScreenShotControl sharedHandler] removeFromSuperview];
    [self.view.window insertSubview:[ScreenShotControl sharedHandler] aboveSubview:self.view];
}

@end

@implementation UIView (SnapShotButton)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(addSubview:);
        SEL swizzledSelector = @selector(snapControlViewAddSubview:);
        SEL addSwizzledSelector = @selector(snapControlViewAddSubviewAdd:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        Method addSwizzledMethod = class_getInstanceMethod(class, addSwizzledSelector);
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(addSwizzledMethod),
                        method_getTypeEncoding(addSwizzledMethod));
        if (!didAddMethod) {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Method Swizzling

-(void)snapControlViewAddSubviewAdd:(UIView*)animated
{
    [[ScreenShotControl sharedHandler] removeFromSuperview];
    [self.window insertSubview:[ScreenShotControl sharedHandler] aboveSubview:self];
}

- (void)snapControlViewAddSubview:(UIView*)animated {
    
    [self snapControlViewAddSubview:animated];
    if (!self.window)
        return;
    [[ScreenShotControl sharedHandler] removeFromSuperview];
    [self.window insertSubview:[ScreenShotControl sharedHandler] aboveSubview:self];
    
}

@end
