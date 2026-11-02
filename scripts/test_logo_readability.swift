import Foundation
import AppKit
import CoreGraphics

let width = 1080
let height = 1920
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let nsImg = NSImage(contentsOfFile: "images/nieuws-edward-vmbo-kader-clinic.jpg"),
      let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else { exit(1) }

// Test Variant 1: White Cutout Corner (Pure White with Orange Slash Border & Original Logo)
func renderVariant1() {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    // Draw background
    let imgOrigW = Double(cgImg.width)
    let imgOrigH = Double(cgImg.height)
    let scale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * 1.05
    ctx.draw(cgImg, in: CGRect(x: (Double(width) - imgOrigW*scale)/2, y: (Double(height) - imgOrigH*scale)/2, width: imgOrigW*scale, height: imgOrigH*scale))

    // 1. Oranje accent-snede (border)
    let orangeSlash = CGMutablePath()
    orangeSlash.move(to: CGPoint(x: 0, y: 1920))
    orangeSlash.addLine(to: CGPoint(x: 580, y: 1920))
    orangeSlash.addLine(to: CGPoint(x: 430, y: 1680))
    orangeSlash.addLine(to: CGPoint(x: 0, y: 1680))
    orangeSlash.closeSubpath()

    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)) // TT Oranje
    ctx.setShadow(offset: CGSize(width: 4, height: -6), blur: 24, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.75))
    ctx.addPath(orangeSlash)
    ctx.fillPath()

    // 2. HELDER WITTE UITGESNEDEN BINNENKANT (Logo 100% leesbaar en contrastrijk!)
    let innerWhite = CGMutablePath()
    innerWhite.move(to: CGPoint(x: 0, y: 1920))
    innerWhite.addLine(to: CGPoint(x: 566, y: 1920))
    innerWhite.addLine(to: CGPoint(x: 418, y: 1688))
    innerWhite.addLine(to: CGPoint(x: 0, y: 1688))
    innerWhite.closeSubpath()

    ctx.setFillColor(CGColor(red: 0.98, green: 0.99, blue: 1.0, alpha: 0.96)) // Wit
    ctx.addPath(innerWhite)
    ctx.fillPath()

    // 3. Swooshes over het wit
    ctx.saveGState()
    ctx.addPath(innerWhite)
    ctx.clip()

    let swooshScale = 2.1
    ctx.translateBy(x: 140, y: 1685)
    ctx.scaleBy(x: CGFloat(swooshScale), y: CGFloat(swooshScale))
    ctx.setAlpha(0.25) // Subtieler op wit zodat logo domineert

    let p1 = CGMutablePath()
    p1.move(to: CGPoint(x: 0, y: 82)); p1.addLine(to: CGPoint(x: 196, y: 8)); p1.addLine(to: CGPoint(x: 176, y: 30)); p1.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.addPath(p1); ctx.fillPath()

    let p2 = CGMutablePath()
    p2.move(to: CGPoint(x: 22, y: 98)); p2.addLine(to: CGPoint(x: 184, y: 44)); p2.addLine(to: CGPoint(x: 170, y: 56)); p2.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.30, alpha: 1.0))
    ctx.addPath(p2); ctx.fillPath()

    let p3 = CGMutablePath()
    p3.move(to: CGPoint(x: 8, y: 58)); p3.addLine(to: CGPoint(x: 150, y: 6)); p3.addLine(to: CGPoint(x: 136, y: 20)); p3.closeSubpath()
    ctx.setFillColor(CGColor(red: 0.70, green: 0.70, blue: 0.70, alpha: 1.0))
    ctx.addPath(p3); ctx.fillPath()
    ctx.restoreGState()

    // 4. Origineel TT Clinics logo op helder wit (loepzuiver en haarscherp leesbaar!)
    if let nsLogo = NSImage(contentsOfFile: "images/logo-lockup-header.png"),
       let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let lw = 360.0
        let lh = lw * (Double(cgLogo.height) / Double(cgLogo.width))
        ctx.draw(cgLogo, in: CGRect(x: 32.0, y: 1740.0, width: lw, height: lh))
    }

    if let outImg = ctx.makeImage() {
        let rep = NSBitmapImageRep(cgImage: outImg)
        let data = rep.representation(using: .jpeg, properties: [:])
        try? data?.write(to: URL(fileURLWithPath: "images/test_white_corner.jpg"))
        print("✓ Variant 1 (White corner) gerenderd")
    }
}

// Test Variant 2: Dark Cutout Corner with WHITE-TEXT Logo
func renderVariant2() {
    let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    
    let imgOrigW = Double(cgImg.width)
    let imgOrigH = Double(cgImg.height)
    let scale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * 1.05
    ctx.draw(cgImg, in: CGRect(x: (Double(width) - imgOrigW*scale)/2, y: (Double(height) - imgOrigH*scale)/2, width: imgOrigW*scale, height: imgOrigH*scale))

    let orangeSlash = CGMutablePath()
    orangeSlash.move(to: CGPoint(x: 0, y: 1920))
    orangeSlash.addLine(to: CGPoint(x: 580, y: 1920))
    orangeSlash.addLine(to: CGPoint(x: 430, y: 1680))
    orangeSlash.addLine(to: CGPoint(x: 0, y: 1680))
    orangeSlash.closeSubpath()

    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.setShadow(offset: CGSize(width: 4, height: -6), blur: 24, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.75))
    ctx.addPath(orangeSlash)
    ctx.fillPath()

    let innerDark = CGMutablePath()
    innerDark.move(to: CGPoint(x: 0, y: 1920))
    innerDark.addLine(to: CGPoint(x: 566, y: 1920))
    innerDark.addLine(to: CGPoint(x: 418, y: 1688))
    innerDark.addLine(to: CGPoint(x: 0, y: 1688))
    innerDark.closeSubpath()

    ctx.setFillColor(CGColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.94))
    ctx.addPath(innerDark)
    ctx.fillPath()

    // Swooshes
    ctx.saveGState()
    ctx.addPath(innerDark)
    ctx.clip()

    let swooshScale = 2.1
    ctx.translateBy(x: 140, y: 1685)
    ctx.scaleBy(x: CGFloat(swooshScale), y: CGFloat(swooshScale))
    ctx.setAlpha(0.85)

    let p1 = CGMutablePath()
    p1.move(to: CGPoint(x: 0, y: 82)); p1.addLine(to: CGPoint(x: 196, y: 8)); p1.addLine(to: CGPoint(x: 176, y: 30)); p1.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.addPath(p1); ctx.fillPath()

    let p2 = CGMutablePath()
    p2.move(to: CGPoint(x: 22, y: 98)); p2.addLine(to: CGPoint(x: 184, y: 44)); p2.addLine(to: CGPoint(x: 170, y: 56)); p2.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.30, alpha: 1.0))
    ctx.addPath(p2); ctx.fillPath()

    let p3 = CGMutablePath()
    p3.move(to: CGPoint(x: 8, y: 58)); p3.addLine(to: CGPoint(x: 150, y: 6)); p3.addLine(to: CGPoint(x: 136, y: 20)); p3.closeSubpath()
    ctx.setFillColor(CGColor(red: 0.70, green: 0.70, blue: 0.70, alpha: 1.0))
    ctx.addPath(p3); ctx.fillPath()
    ctx.restoreGState()

    // Logo met WITTE letters
    if let nsLogo = NSImage(contentsOfFile: "images/logo-lockup-white.png"),
       let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        let lw = 360.0
        let lh = lw * (Double(cgLogo.height) / Double(cgLogo.width))
        ctx.draw(cgLogo, in: CGRect(x: 32.0, y: 1740.0, width: lw, height: lh))
    }

    if let outImg = ctx.makeImage() {
        let rep = NSBitmapImageRep(cgImage: outImg)
        let data = rep.representation(using: .jpeg, properties: [:])
        try? data?.write(to: URL(fileURLWithPath: "images/test_white_logo.jpg"))
        print("✓ Variant 2 (White-text logo) gerenderd")
    }
}

renderVariant1()
renderVariant2()
