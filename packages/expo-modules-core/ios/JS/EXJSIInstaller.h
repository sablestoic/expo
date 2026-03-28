// Copyright 2018-present 650 Industries. All rights reserved.

#if !__building_module(ExpoModulesCore)
#import <React/RCTBridge.h>
#else
@class RCTBridge;
#endif

// Forward declarations for types - use protocol for AppContext to avoid Swift.h import
@class EXAppContext;
@class EXRuntime;
@class EXJavaScriptRuntime;
@protocol EXAppContextProtocol;

#if __has_include(<ReactCommon/RCTRuntimeExecutor.h>)
@class RCTRuntimeExecutor;
#endif // React Native >=0.74

/**
 Property name of the core object in the global scope of the Expo JS runtime.
 */
extern NSString *_Nonnull const EXGlobalCoreObjectPropertyName;

@interface EXJavaScriptRuntimeManager : NSObject

/**
 Initializes the runtime installer with a raw pointer to the runtime.
 It must be a raw pointer instead of `jsi::Runtime` to be visible for Swift without C++ interop.
 */
+ (nullable EXRuntime *)runtimeFromBridge:(nonnull RCTBridge *)bridge NS_SWIFT_NAME(runtime(fromBridge:));

#if __has_include(<ReactCommon/RCTRuntimeExecutor.h>)
+ (nullable EXRuntime *)runtimeFromBridge:(nonnull RCTBridge *)bridge withExecutor:(nonnull RCTRuntimeExecutor *)executor;
#endif // React Native >=0.74

/**
 Installs ExpoModules host object in the runtime of the given app context.
 Returns a bool value whether the installation succeeded.
 */
+ (BOOL)installExpoModulesHostObject:(nonnull id<EXAppContextProtocol>)appContext;

/**
 Installs the base class for shared objects, i.e. `global.expo.SharedObject`.
 */
- (void)installSharedObjectClass:(void (^_Nonnull)(long))releaser;

/**
 Installs the base class for shared refs, i.e. `global.expo.SharedRef`.
 */
- (void)installSharedRefClass;

/**
 Installs the EventEmitter class in the given runtime as `global.expo.EventEmitter`.
 */
- (void)installEventEmitterClass;

/**
 Installs the NativeModule class in the given runtime as `global.expo.NativeModule`.
 */
- (void)installNativeModuleClass;

@end
