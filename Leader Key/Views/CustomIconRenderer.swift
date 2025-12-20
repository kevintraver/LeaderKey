import AppKit

enum CustomIconRenderer {
  static let cornerRadiusFactor: CGFloat = 0.2237

  static func isCustomImagePath(_ path: String) -> Bool {
    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && !isDirectory.boolValue
  }

  static func renderCustomIcon(from path: String, size: NSSize) -> NSImage? {
    guard isCustomImagePath(path),
          let image = NSImage(contentsOfFile: path) else {
      return nil
    }
    return render(image, size: size)
  }

  static func render(_ image: NSImage, size: NSSize) -> NSImage {
    let targetSize = NSSize(width: size.width, height: size.height)
    let outputImage = NSImage(size: targetSize)

    outputImage.lockFocus()
    defer { outputImage.unlockFocus() }

    let destRect = NSRect(origin: .zero, size: targetSize)
    let cornerRadius = min(size.width, size.height) * cornerRadiusFactor
    let clipPath = NSBezierPath(roundedRect: destRect, xRadius: cornerRadius, yRadius: cornerRadius)
    clipPath.addClip()

    let drawRect = aspectFillRect(for: image.size, in: destRect)
    image.draw(
      in: drawRect,
      from: NSRect(origin: .zero, size: image.size),
      operation: .sourceOver,
      fraction: 1.0
    )

    return outputImage
  }

  private static func aspectFillRect(for sourceSize: NSSize, in destRect: NSRect) -> NSRect {
    guard sourceSize.width > 0, sourceSize.height > 0 else { return destRect }

    let widthScale = destRect.width / sourceSize.width
    let heightScale = destRect.height / sourceSize.height
    let scale = max(widthScale, heightScale)
    let scaledSize = NSSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
    let origin = NSPoint(
      x: destRect.midX - scaledSize.width / 2,
      y: destRect.midY - scaledSize.height / 2
    )

    return NSRect(origin: origin, size: scaledSize)
  }
}
