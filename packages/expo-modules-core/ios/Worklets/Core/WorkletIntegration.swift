// Copyright 2025-present 650 Industries. All rights reserved.

import ExpoModulesCore
import ExpoModulesJSI

/// Registers the worklet runtime factory with ExpoModulesCore.
/// This is called automatically via +load in WorkletIntegrationLoader.mm.
@objc(EXWorkletIntegration)
public final class WorkletIntegration: NSObject {
  @objc public static func register() {
    AppContext.uiRuntimeFactory = { appContext, pointerValue, runtime in
      let pointerHolder = try pointerValue.asObject()

      guard pointerHolder.isArrayBuffer() else {
        throw WorkletRuntimePointerExtractionException()
      }
      let arrayBuffer = pointerHolder.getArrayBuffer()

      guard arrayBuffer.size == MemoryLayout<UnsafeMutableRawPointer>.size else {
        throw WorkletRuntimePointerExtractionException()
      }
      let runtimePointer = arrayBuffer.data().withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
        return $0.pointee
      }
      guard let workletRuntime = WorkletRuntime(runtimePointer: runtimePointer) else {
        throw WorkletRuntimePointerExtractionException()
      }
      return workletRuntime
    }
  }
}

private final class WorkletRuntimePointerExtractionException: Exception, @unchecked Sendable {
  override var reason: String {
    "Cannot extract pointer to UI worklet runtime"
  }
}
