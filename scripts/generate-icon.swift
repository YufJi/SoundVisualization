import AppKit

let arguments = CommandLine.arguments
guard arguments.count == 2 else {
    FileHandle.standardError.write("Usage: generate-icon.swift OUTPUT_PNG\n".data(using: .utf8)!)
    exit(1)
}

let outputURL = URL(fileURLWithPath: arguments[1])
let canvasSize = NSSize(width: 1024, height: 1024)
let iconRect = NSRect(x: 100, y: 100, width: 824, height: 824)
let image = NSImage(size: canvasSize)

image.lockFocusFlipped(false)

let iconPath = NSBezierPath(roundedRect: iconRect, xRadius: 184, yRadius: 184)
let backgroundGradient = NSGradient(colors: [
    NSColor(red: 0.11, green: 0.13, blue: 0.25, alpha: 1),
    NSColor(red: 0.26, green: 0.16, blue: 0.52, alpha: 1),
    NSColor(red: 0.02, green: 0.55, blue: 0.68, alpha: 1)
])
backgroundGradient?.draw(in: iconPath, angle: -72)

let highlightPath = NSBezierPath(roundedRect: iconRect, xRadius: 184, yRadius: 184)
NSGraphicsContext.current?.saveGraphicsState()
highlightPath.appendRect(NSRect(x: 100, y: 540, width: 824, height: 384))
highlightPath.addClip()
let highlightGradient = NSGradient(colors: [
    NSColor.white.withAlphaComponent(0.16),
    NSColor.white.withAlphaComponent(0)
])
highlightGradient?.draw(in: highlightPath, angle: -90)
NSGraphicsContext.current?.restoreGraphicsState()

let barFractions: [CGFloat] = [
    0.24, 0.42, 0.64, 0.84, 0.98, 0.70,
    0.88, 0.58, 0.76, 0.42, 0.60, 0.30
]
let barWidth: CGFloat = 22
let barSpacing: CGFloat = 24
let barsWidth = CGFloat(barFractions.count) * barWidth + CGFloat(barFractions.count - 1) * barSpacing
let barsLeft = iconRect.midX - barsWidth / 2
let maximumBarHeight: CGFloat = 520

NSColor.white.withAlphaComponent(0.94).setFill()
for (index, fraction) in barFractions.enumerated() {
    let barHeight = max(48, maximumBarHeight * fraction)
    let barRect = NSRect(
        x: barsLeft + CGFloat(index) * (barWidth + barSpacing),
        y: iconRect.midY - barHeight / 2,
        width: barWidth,
        height: barHeight
    )
    NSBezierPath(roundedRect: barRect, xRadius: barWidth / 2, yRadius: barWidth / 2).fill()
}

iconPath.lineWidth = 3
NSColor.white.withAlphaComponent(0.10).setStroke()
iconPath.stroke()

image.unlockFocus()

guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("Unable to render icon bitmap.\n".data(using: .utf8)!)
    exit(1)
}

let bitmap = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write("Unable to encode icon PNG.\n".data(using: .utf8)!)
    exit(1)
}

do {
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try pngData.write(to: outputURL)
} catch {
    FileHandle.standardError.write("Unable to write icon: \(error)\n".data(using: .utf8)!)
    exit(1)
}
