import ExpoModulesJSI

/**
 Represents a JS native state that is attached to shared objects.
 - ToDo: Make `SharedObject` class a native state on its own.
 */
internal final class SharedObjectNativeState: JavaScriptNativeState {
  let id: SharedObjectId

  init(id: SharedObjectId, _ deallocator: Deallocator? = nil) {
    self.id = id
    super.init(deallocator)
  }
}
