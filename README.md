# JkQRScanner

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- Minimum deployement: iOS 13 and above
- Add Privacy Camera Usage Description

## Installation

JkQRScanner is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JkQRScanner'
```

## Usage
First of all import JkQRScanner
```swift
import JkQRScanner
```

Initialize the JkQRScanner object and provide a UIView as the inputView in which you wish to add the QR Scanner

```swift
var qrScanner: JkQRScanner!
    
override func viewDidLoad() {
  super.viewDidLoad()
        
  qrScanner = JkQRScanner(delegate: self,
                          inputView: view,
                          message: "Align your QR with the box",
                          addFlashlight: true,
                          addPickFromPhotoLibraryOption: true)
  qrScanner.startRunning()
}

```

Also implement the QRScannerDelegate
```swift 
extension ViewController: JkQRScannerDelegate {
    //this delegate method will provide the output of the scanner
    func qrScanner(_ scanner: JkQRScanner, didScanQRCode code: String) {
        print("Scanner output: \(code)")
        qrScanner.stopRunning()
    }
    
    func qrScannerDidDenyCameraUsageAuthorization() {
        // you can redirect user to your app's settings in Settings App to allow camera permission
        goToAppSettings()
    }
    
    func qrScannerDidApproveCameraUsageAuthorization() {
        // perform any actions as per your requirements when the camera permission is allowed
    }

    // function to go to App's settings in Settings App
    private func goToAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            // add your custom message
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}

```

## Author

Jay Kothadia, jay.kothadia@gmail.com

## License

JkQRScanner is available under the MIT license. See the LICENSE file for more info.
