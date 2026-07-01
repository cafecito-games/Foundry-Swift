# iOS Platform Integration

This page contains some examples of code that might be useful to combine Foundry
with iOS APIs.

## Converting a Viewport into an Image

If you happen to have a viewport, you can create a screenshot of it like this:

```swift
func getImage (from: SceneTree) -> FoundrySwift.Image? {
	from.root?.getViewport()?.getTexture()?.getImage()
}
```

## Converting a FoundrySwift.image into a UIImage

This function will attempt to convert a FoundrySwift image into a UIImage:

```swift
extension FoundrySwift.Image {
    func toUIImage() -> UIImage? {
        let width = Int(getWidth())
        let height = Int(getHeight())
        
        // Ensure the image format is compatible (RGBA8)
        if getFormat() != Image.Format.rgba8 {
            convert(format: Image.Format.rgba8)
        }
        
        guard let pixelData = getData().asData() else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let provider = CGDataProvider(data: pixelData as CFData) else { return nil }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
```

## Converting a FoundrySwift.Color into a SwiftUI.Color

```swift
extension FoundrySwift.Color {
    /// Creates a SwiftUI.Color from a FoundrySwift.Color
    public func asSwiftUI() -> SwiftUI.Color {
        SwiftUI.Color(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            opacity: Double(alpha)
        )
    }
}
```

### Converting PackedByteArray into a Swift Data 

```swift
extension PackedByteArray {
    public func asData() -> Data? {
        return withUnsafeAccessToData { ptr, count in Data (bytes: ptr, count: count) }
    }
}
```


### Making FoundryError conform to LocalizedError

This is convenient if you want to easily bubble up FoundryError messages in
SwiftUI:

```swift

// The @retroactive is to avoid the warning on LocalizedError, which is not on FoundrySwift,
// because FoundrySwift avoids taking a dependency on Foundation
extension FoundryError: @retroactive LocalizedError {
    public var failureReason: String? {
        return localizedDescription
    }
    public var errorDescription: String? {
        return localizedDescription
    }
}
```