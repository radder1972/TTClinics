import Foundation
import AppKit
import CoreGraphics
import CoreText

let width = 1080
let height = 1920
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let nsImg = NSImage(contentsOfFile: "images/zaal-toernooi-opgeflufft.jpg"),
      let cgImg = nsImg.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Cannot load image")
    exit(1)
}

let ctx = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: width * 4,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
)!

let imgOrigW = Double(cgImg.width)
let imgOrigH = Double(cgImg.height)

// 1. FULL BLEED EDGE-TO-EDGE
let baseScale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * 1.06
let drawW = imgOrigW * baseScale
let drawH = imgOrigH * baseScale
let drawX = (Double(width) - drawW) / 2.0
let drawY = (Double(height) - drawH) / 2.0
ctx.draw(cgImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))

// 2. Gradiënten voor vloeiende doorkijk zonder zwarte balken
let bottomColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.88),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.55),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let bottomLocs: [CGFloat] = [0.0, 0.55, 1.0]
if let grad = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: bottomLocs) {
    ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 720), options: [])
}

let topColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.75),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let topLocs: [CGFloat] = [0.0, 1.0]
if let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: topLocs) {
    ctx.drawLinearGradient(topGrad, start: CGPoint(x: 0, y: 1920), end: CGPoint(x: 0, y: 1650), options: [])
}

// 3. HOEK GERESERVEERD VOOR TT CLINICS LOGO EN SWOOSHES
ctx.saveGState()

// Achtergrond badge in de linkerbovenhoek
let cornerBadgeRect = CGRect(x: 44, y: 1730, width: 440, height: 130)
let cornerPath = CGPath(roundedRect: cornerBadgeRect, cornerWidth: 24, cornerHeight: 24, transform: nil)

ctx.setFillColor(CGColor(red: 0.06, green: 0.09, blue: 0.14, alpha: 0.82))
ctx.addPath(cornerPath)
ctx.fillPath()

// Oranje subtiele rand
ctx.setStrokeColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.55))
ctx.setLineWidth(2.0)
ctx.addPath(cornerPath)
ctx.strokePath()

// Teken de scherpe TT swooshes achter het logo binnen het hoekje
ctx.saveGState()
ctx.addPath(cornerPath)
ctx.clip()

let swooshScale = 1.8
let swooshX = 220.0
let swooshY = 1715.0
ctx.translateBy(x: CGFloat(swooshX), y: CGFloat(swooshY))
ctx.scaleBy(x: CGFloat(swooshScale), y: CGFloat(swooshScale))
ctx.setAlpha(0.85)

// 1. Oranje hoofdstreak
let p1 = CGMutablePath()
p1.move(to: CGPoint(x: 0, y: 82))
p1.addLine(to: CGPoint(x: 196, y: 8))
p1.addLine(to: CGPoint(x: 176, y: 30))
p1.closeSubpath()
ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
ctx.addPath(p1)
ctx.fillPath()

// 2. Lichtoranje streak
let p2 = CGMutablePath()
p2.move(to: CGPoint(x: 22, y: 98))
p2.addLine(to: CGPoint(x: 184, y: 44))
p2.addLine(to: CGPoint(x: 170, y: 56))
p2.closeSubpath()
ctx.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.30, alpha: 1.0))
ctx.addPath(p2)
ctx.fillPath()

// 3. Grijze streak
let p3 = CGMutablePath()
p3.move(to: CGPoint(x: 8, y: 58))
p3.addLine(to: CGPoint(x: 150, y: 6))
p3.addLine(to: CGPoint(x: 136, y: 20))
p3.closeSubpath()
ctx.setFillColor(CGColor(red: 0.70, green: 0.70, blue: 0.70, alpha: 1.0))
ctx.addPath(p3)
ctx.fillPath()

ctx.restoreGState()

// Logo bovenop de swooshes in de hoek
if let nsLogo = NSImage(contentsOfFile: "images/logo-lockup-header.png"),
   let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    let lw = 360.0
    let lh = lw * (Double(cgLogo.height) / Double(cgLogo.width))
    let lx = 60.0
    let ly = 1730.0 + (130.0 - lh) / 2.0
    ctx.draw(cgLogo, in: CGRect(x: lx, y: ly, width: lw, height: lh))
}
ctx.restoreGState()

// 4. EIGEN 2D ICOON EN TEKST ONDERAAN
ctx.saveGState()

// Teken het 2D icoon van deze scène (bijv. icon-location.png)
let iconX = 56.0
let iconY = 410.0
let iconSize = 96.0

if let nsIcon = NSImage(contentsOfFile: "images/icon-location.png"),
   let cgIcon = nsIcon.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    // Schaduw achter het icoon
    ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.8))
    ctx.draw(cgIcon, in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
}

// Tekst naast en onder het icoon
ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))

// Tag naast icoon
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 24, weight: .black),
    .foregroundColor: NSColor(red: 1.0, green: 0.52, blue: 0.1, alpha: 1.0)
]
let tagLine = CTLineCreateWithAttributedString(NSAttributedString(string: "DE LOCATIE · WEESP & KANTOOR", attributes: tagAttrs))
ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 54)
CTLineDraw(tagLine, ctx)

// Sub-tag naast icoon
let subtagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 20, weight: .bold),
    .foregroundColor: NSColor(white: 0.85, alpha: 1.0)
]
let subtagLine = CTLineCreateWithAttributedString(NSAttributedString(string: "THUISBASIS THE VICTORY", attributes: subtagAttrs))
ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 16)
CTLineDraw(subtagLine, ctx)

// Grote Titel
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 50, weight: .heavy),
    .foregroundColor: NSColor.white
]
let titleLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Professionele zaal & topsfeer", attributes: titleAttrs))
ctx.textPosition = CGPoint(x: 56, y: 330)
CTLineDraw(titleLine, ctx)

// Gesproken ondertitel (Roos voiceover)
let subAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
    .foregroundColor: NSColor(white: 0.94, alpha: 1.0)
]
let subLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Bij The Victory in Weesp én compleet op jullie locatie!", attributes: subAttrs))
ctx.textPosition = CGPoint(x: 56, y: 260)
CTLineDraw(subLine, ctx)

// CTA
let ctaAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 24, weight: .bold),
    .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
]
let ctaLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Boek direct online ➔ ttclinics.nl", attributes: ctaAttrs))
ctx.textPosition = CGPoint(x: 56, y: 195)
CTLineDraw(ctaLine, ctx)

ctx.restoreGState()

// 5. Oranje progress line onderaan
ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: 450, height: 10))

if let outImg = ctx.makeImage() {
    let rep = NSBitmapImageRep(cgImage: outImg)
    let data = rep.representation(using: .jpeg, properties: [:])
    try? data?.write(to: URL(fileURLWithPath: "images/test_scene_frame.jpg"))
    print("✓ test_scene_frame.jpg gerenderd!")
}
