// Copyright 2018-present 650 Industries. All rights reserved.

#import <ExpoModulesJSI/BridgelessJSCallInvoker.h>

#import <ExpoModulesCore/EXAppContextProtocol.h>
#import <ExpoModulesCore/EXJSIInstaller.h>
#import <ExpoModulesCore/SharedObject.h>
#import <ExpoModulesCore/SharedRef.h>
#import <ExpoModulesCore/EventEmitter.h>
#import <ExpoModulesCore/NativeModule.h>
#import <ExpoModulesCore/EXRuntime.h>
#import <ExpoModulesJSI/EXJSIUtils.h>

#import <react/renderer/runtimescheduler/RuntimeScheduler.h>
#import <react/renderer/runtimescheduler/RuntimeSchedulerBinding.h>

namespace jsi = facebook::jsi;

/**
 Property name of the core object in the global scope of the Expo JS runtime.
 */
NSString *const EXGlobalCoreObjectPropertyName = @"expo";

/**
 Property name used to define the modules host object in the main object of the
 Expo JS runtime.
 */
static NSString *modulesHostObjectPropertyName = @"modules";

@implementation EXJavaScriptRuntimeManager {
  std::shared_ptr<jsi::Runtime> _runtime;
}

- (nonnull instancetype)initWithRuntime:(nonnull void *)runtime
{
  if (self = [super init]) {
    // Make shared pointer that points to the runtime but doesn't own it, thus doesn't release it.
    _runtime = std::shared_ptr<jsi::Runtime>(std::shared_ptr<jsi::Runtime>(), reinterpret_cast<jsi::Runtime *>(runtime));
  }
  return self;
}

#pragma mark - Installing JSI bindings

+ (BOOL)installExpoModulesHostObject:(nonnull id<EXAppContextProtocol>)appContext
{
  EXRuntime *runtime = [appContext _runtime];

  // The runtime may be unavailable, e.g. remote debugger is enabled or it hasn't been set yet.
  if (!runtime) {
    return false;
  }

  EXJavaScriptObject *global = [runtime global];
  EXJavaScriptValue *coreProperty = [global getProperty:EXGlobalCoreObjectPropertyName];
  NSAssert([coreProperty isObject], @"The global core property should be an object");
  EXJavaScriptObject *coreObject = [coreProperty getObject];

  if ([coreObject hasProperty:modulesHostObjectPropertyName]) {
    return false;
  }

  // Cast protocol to EXAppContext* for the C++ ExpoModulesHostObject
  // constructor This is safe because EXAppContext is the ObjC name for Swift's
  // AppContext class
  EXAppContext *appContextObj = (EXAppContext *)appContext;
  std::shared_ptr<expo::ExpoModulesHostObject> modulesHostObjectPtr = std::make_shared<expo::ExpoModulesHostObject>(appContextObj);
  EXJavaScriptObject *modulesHostObject = [runtime createHostObject:modulesHostObjectPtr];

  // Define the `global.expo.modules` object as a non-configurable, read-only and enumerable property.
  [coreObject defineProperty:modulesHostObjectPropertyName
                       value:modulesHostObject
                     options:EXJavaScriptObjectPropertyDescriptorEnumerable];

  return true;
}

+ (void)installSharedObjectClass:(nonnull EXRuntime *)runtime releaser:(void(^)(long))releaser
{
  expo::SharedObject::installBaseClass(*[runtime get], [releaser](expo::SharedObject::ObjectId objectId) {
    releaser(objectId);
  });
}

- (void)installSharedRefClass
{
  expo::SharedRef::installBaseClass(*_runtime);
}

- (void)installEventEmitterClass
{
  expo::EventEmitter::installClass(*_runtime);
}

- (void)installNativeModuleClass
{
  expo::NativeModule::installClass(*_runtime);
}

@end
