// Copyright 2025-present 650 Industries. All rights reserved.

#import <ExpoModulesWorklets/WorkletRuntimeHandle.h>

#if WORKLETS_ENABLED

#import "EXJavaScriptSerializable+Private.h"
//#import <ExpoModulesJSI/EXJSIConversions.h>
#import <worklets/WorkletRuntime/WorkletRuntime.h>

@implementation EXWorkletRuntimeHandle {
  std::weak_ptr<worklets::WorkletRuntime> _workletRuntime;
  jsi::Runtime *_jsiRuntime;
}

- (nullable instancetype)initWithRawPointer:(void *)pointer
{
  if (self = [super init]) {
    _jsiRuntime = reinterpret_cast<jsi::Runtime *>(pointer);

    auto weakRuntime = worklets::WorkletRuntime::getWeakRuntimeFromJSIRuntime(*_jsiRuntime);
    auto locked = weakRuntime.lock();
    if (!locked) {
      return nil;
    }
    _workletRuntime = weakRuntime;
  }
  return self;
}

#pragma mark - Schedule (async)

- (void)scheduleWorklet:(EXJavaScriptSerializable *)serializable
              arguments:(NSArray *)arguments
{
  auto workletRuntime = _workletRuntime.lock();
  if (!workletRuntime) {
    return;
  }

  auto worklet = std::dynamic_pointer_cast<worklets::SerializableWorklet>(
    [serializable getSerializable]
  );
  if (!worklet) {
    return;
  }

  workletRuntime->schedule([worklet, arguments](jsi::Runtime &rt) {
//    auto convertedArgs = expo::convertNSArrayToStdVector(rt, arguments);
//    auto func = worklet->toJSValue(rt).asObject(rt).asFunction(rt);
//    func.call(rt, (const jsi::Value *)convertedArgs.data(), convertedArgs.size());
  });
}

#pragma mark - Execute (sync)

- (void)executeWorklet:(EXJavaScriptSerializable *)serializable
             arguments:(NSArray *)arguments
{
  auto workletRuntime = _workletRuntime.lock();
  if (!workletRuntime) {
    return;
  }

  auto worklet = std::dynamic_pointer_cast<worklets::SerializableWorklet>(
    [serializable getSerializable]
  );
  if (!worklet) {
    return;
  }

  workletRuntime->executeSync([worklet, arguments](jsi::Runtime &rt) -> jsi::Value {
//    auto convertedArgs = expo::convertNSArrayToStdVector(rt, arguments);
//    auto func = worklet->toJSValue(rt).asObject(rt).asFunction(rt);
//    func.call(rt, (const jsi::Value *)convertedArgs.data(), convertedArgs.size());
    return jsi::Value::undefined();
  });
}

@end

#else

#import <ExpoModulesWorklets/EXJavaScriptSerializable.h>

@implementation EXWorkletRuntimeHandle

- (nullable instancetype)initWithRawPointer:(void *)pointer
{
  @throw [NSException exceptionWithName:@"WorkletException"
                                 reason:@"Worklets integration is disabled"
                               userInfo:nil];
}

- (void)scheduleWorklet:(EXJavaScriptSerializable *)serializable
              arguments:(NSArray *)arguments
{
  @throw [NSException exceptionWithName:@"WorkletException"
                                 reason:@"Worklets integration is disabled"
                               userInfo:nil];
}

- (void)executeWorklet:(EXJavaScriptSerializable *)serializable
             arguments:(NSArray *)arguments
{
  @throw [NSException exceptionWithName:@"WorkletException"
                                 reason:@"Worklets integration is disabled"
                               userInfo:nil];
}

@end

#endif
