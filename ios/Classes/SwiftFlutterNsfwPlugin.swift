import UIKit
import Flutter
import NSFWDetector
import AVFoundation



enum FlutterNSFWError: Error {
    case unknownMethod
}


public class SwiftFlutterNsfwPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_nsfw", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNsfwPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        do{
            switch call.method {
            case "getBitmapNSFWScore":
                guard let arguments = call.arguments as? [AnyHashable: Any] else { return }
                guard let imageData = arguments["imageData"] as? FlutterStandardTypedData else { return }
                guard let image:UIImage = UIImage(data: imageData.data) else { return }
                
                let detector = NSFWDetector.shared
                detector.check(image: image, completion: { nsfwResult in
                    switch nsfwResult {
                    case let .success(nsfwConfidence: confidence):
                        print("detector check Confidance",confidence)
                        result(confidence)
                    case let .error(error):
                        print("detector check error",error)
                        result(nil)
                    }
                })
                
            default:
                throw FlutterNSFWError.unknownMethod
            }
        } catch {
            print("FlutterNSFWError bridge error: \(error)")
            result(nil)
        }
    }
}
