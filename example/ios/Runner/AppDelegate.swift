import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Benchmark helpers for the native blur comparison screen.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeBlurBench") {
      registrar.register(NativeBlurFactory(), withId: "native-blur")
      let channel = FlutterMethodChannel(
        name: "bench/memory", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        if call.method == "footprint" {
          result(NSNumber(value: AppDelegate.memoryFootprint()))
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  /// The app's memory footprint in bytes: the number Xcode's memory gauge shows.
  static func memoryFootprint() -> Int64 {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(
      MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
    let kr = withUnsafeMutablePointer(to: &info) {
      $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
      }
    }
    return kr == KERN_SUCCESS ? Int64(info.phys_footprint) : -1
  }
}

/// A plain UIKit blur, for comparing against VariableBlur.
class NativeBlurFactory: NSObject, FlutterPlatformViewFactory {
  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    return NativeBlurView(frame: frame)
  }
}

class NativeBlurView: NSObject, FlutterPlatformView {
  private let blur: UIVisualEffectView

  init(frame: CGRect) {
    blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    blur.frame = frame
    super.init()
  }

  func view() -> UIView { blur }
}
