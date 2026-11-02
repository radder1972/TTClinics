import Foundation
import AppKit
import CoreGraphics
import CoreText

let width = 1080
let height = 1920
let colorSpace = CGColorSpaceCreateDeviceRGB()

let ctx = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

// Background dark for testing
ctx.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

// Functie om de officiële TT Clinics swooshes te tekenen
func drawTTSwooshes(in context: CGContext, originX: Double, originY: Double, scale: Double, alpha: Double = 1.0) {
    context.saveGState()
    context.translateBy(x: CGFloat(originX), y: CGFloat(originY))
    context.scaleBy(x: CGFloat(scale), y: CGFloat(scale))
    context.setAlpha(CGFloat(alpha))

    // Swoosh 1: Oranje hoofdswoosh (M0,82 L196,8 L176,30 Z)
    let path1 = CGMutablePath()
    path1.move(to: CGPoint(x: 0, y: 82))
    path1.addLine(to: CGPoint(x: 196, y: 8))
    path1.addLine(to: CGPoint(x: 176, y: 30))
    path1.closeSubpath()
    context.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)) // #FF6B00
    context.addPath(path1)
    context.fillPath()

    // Swoosh 2: Licht oranje highlightswoosh (M22,98 L184,44 L170,56 Z)
    let path2 = CGMutablePath()
    path2.move(to: CGPoint(x: 22, y: 98))
    path2.addLine(to: CGPoint(x: 184, y: 44))
    path2.addLine(to: CGPoint(x: 170, y: 56))
    path2.closeSubpath()
    context.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.30, alpha: 1.0)) // #FF9A4D
    context.addPath(path2)
    context.fillPath()

    // Swoosh 3: Grijze dynamische swoosh (M8,58 L150,6 L136,20 Z)
    let path3 = CGMutablePath()
    path3.move(to: CGPoint(x: 8, y: 58))
    path3.addLine(to: CGPoint(x: 150, y: 6))
    path3.addLine(to: CGPoint(x: 136, y: 20))
    path3.closeSubpath()
    context.setFillColor(CGColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.0)) // #7A7A7A
    context.addPath(path3)
    context.fillPath()

    context.restoreGState()
}

// Teken swooshes in hoek
drawTTSwooshes(in: ctx, originX: 40, originY: 1720, scale: 2.2, alpha: 0.95)

// Laad logo
if let nsLogo = NSImage(contentsOfFile: "images/logo-transparent.png"),
   let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    let logoW = 200.0
    let logoH = logoW * (Double(cgLogo.height) / Double(cgLogo.width))
    ctx.draw(cgLogo, in: CGRect(x: 60, y: 1730, width: logoW, height: logoH))
}

// Laad 2D icoon
if let nsIcon = NSImage(contentsOfFile: "images/icon-trophy.png"),
   let cgIcon = nsIcon.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    ctx.draw(cgIcon, in: CGRect(x: 60, y: 350, width: 80, height: 80))
}

if let outImg = ctx.makeImage() {
    let rep = NSBitmapImageRep(cgImage: outImg)
    let data = rep.representation(using: .jpeg, properties: [:])
    try? data?.write(to: URL(fileURLWithPath: "images/test_logo_corner.jpg"))
    print("✓ test_logo_corner.jpg gerenderd!")
}
