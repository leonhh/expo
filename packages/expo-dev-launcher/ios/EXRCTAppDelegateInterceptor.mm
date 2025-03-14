// Copyright 2018-present 650 Industries. All rights reserved.

#import <EXDevLauncher/EXRCTAppDelegateInterceptor.h>

#import <memory>
#import <cxxreact/JSExecutor.h>
#import <React/RCTCxxBridgeDelegate.h>

@interface DevClientReactNativeFactoryDelegate () <RCTCxxBridgeDelegate>
@end

@implementation EXRCTAppDelegateInterceptor

- (instancetype)initWithBridgeDelegate:(id<RCTBridgeDelegate>)bridgeDelegate interceptor:(id<RCTBridgeDelegate>)interceptor
{
  if (self = [super init]) {
    self.bridgeDelegate = bridgeDelegate;
    self.interceptor = interceptor;
  }
  return self;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
  return [self.bridgeDelegate conformsToProtocol:protocol];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
  if ([self isInterceptedSelector:selector]) {
    return self;
  }
  return self.bridgeDelegate;
}

- (BOOL)respondsToSelector:(SEL)selector
{
  if ([self isInterceptedSelector:selector]) {
    return YES;
  }
  return [self.bridgeDelegate respondsToSelector:selector];
}

- (BOOL)isInterceptedSelector:(SEL)selector
{
  if ([self.interceptor respondsToSelector:selector]) {
    return YES;
  }
  return NO;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [self.interceptor sourceURLForBridge:bridge];
}

- (NSURL *)bundleURL {
  // Passing nil bridge because the underlying `sourceURLForBridge:` doesn't use the bridge.
  return [self.interceptor sourceURLForBridge:nil];
}

@end
