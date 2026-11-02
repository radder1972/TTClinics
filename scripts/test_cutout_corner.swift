import Foundation
import AppKit
import CoreGraphics
import CoreText

let width = 1080
let height = 1920
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let nsImg = NSImage(contentsOfFile: "images/nieuws-edward-vmbo-kader-clinic.jpg"),
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

// 1. Fullscreen Image
let imgOrigW = Double(cgImg.width)
let imgOrigH = Double(cgImg.height)
let baseScale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * 1.05
let drawW = imgOrigW * baseScale
let drawH = imgOrigH * baseScale
let drawX = (Double(width) - drawW) / 2.0
let drawY = (Double(height) - drawH) / 2.0
ctx.draw(cgImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))

// 2. Gradients
let bottomColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.90),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.55),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let bottomLocs: [CGFloat] = [0.0, 0.55, 1.0]
if let grad = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: bottomLocs) {
    ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 720), options: [])
}

// 3. ECHTE UITGESNEDEN HOEK (GEEN RECHTHOEKIG BLOK!)
// Een dynamische diagonale uitsparing vanuit de linkerbovenrand (0, 1920)
ctx.saveGState()

// A. Oranje diagonale accentstrook (de schuine oranje snede)
let orangeSlashPath = CGMutablePath()
orangeSlashPath.move(to: CGPoint(x: 0, y: 1920))
orangeSlashPath.addLine(to: CGPoint(x: 580, y: 1920))
orangeSlashPath.addLine(to: CGPoint(x: 430, y: 1680))
orangeSlashPath.addLine(to: CGPoint(x: 0, y: 1680))
orangeSlashPath.closeSubpath()

ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)) // TT Oranje
ctx.setShadow(offset: CGSize(width: 4, height: -6), blur: 24, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.75))
ctx.addPath(orangeSlashPath)
ctx.fillPath()

// B. Donkere binnenkant van de uitgesneden hoek (met 6px oranje rand aan de schuine kant)
let innerCutoutPath = CGMutablePath()
innerCutoutPath.move(to: CGPoint(x: 0, y: 1920))
innerCutoutPath.addLine(to: CGPoint(x: 566, y: 1920))
innerCutoutPath.addLine(to: CGPoint(x: 418, y: 1688))
innerCutoutPath.addLine(to: CGPoint(x: 0, y: 1688))
innerCutoutPath.closeSubpath()

ctx.setFillColor(CGColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.94))
ctx.addPath(innerCutoutPath)
ctx.fillPath()

// C. Dynamische TT swooshes die UIT de uitgesneden hoek snijden!
ctx.saveGState()
// Clip tot de hoek plus een stuk dat naar rechts uitsteekt over het beeld
let swooshClip = CGMutablePath()
swooshClip.move(to: CGPoint(x: 0, y: 1920))
swooshClip.addLine(to: CGPoint(x: 750, y: 1920))
swooshClip.addLine(to: CGPoint(x: 418, y: 1680))
swooshClip.addLine(to: CGPoint(x: 0, y: 1680))
swooshClip.closeSubpath()
ctx.addPath(swooshClip)
ctx.clip()

let swooshX = 140.0
let swooshY = 1685.0
let swooshScale = 2.1
ctx.translateBy(x: CGFloat(swooshX), y: CGFloat(swooshY))
ctx.scaleBy(x: CGFloat(swooshScale), y: CGFloat(swooshScale))
ctx.setAlpha(0.88)

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

// D. TT Clinics Logo in de uitgesneden hoek
if let nsLogo = NSImage(contentsOfFile: "images/logo-lockup-header.png"),
   let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    let lw = 360.0
    let lh = lw * (Double(cgLogo.height) / Double(cgLogo.width))
    let lx = 32.0
    let ly = 1740.0
    ctx.draw(cgLogo, in: CGRect(x: lx, y: ly, width: lw, height: lh))
}

ctx.restoreGState()

// 4. Scène 2 (Edward) 2D Icoon en Tekst onderaan
ctx.saveGState()

let iconX = 56.0
let iconY = 410.0
let iconSize = 96.0

if let nsIcon = NSImage(contentsOfFile: "images/icon-heartbeat.png"),
   let cgIcon = nsIcon.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 18, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))
    ctx.draw(cgIcon, in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
}

ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))

// Tag
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 24, weight: .black),
    .foregroundColor: NSColor(red: 1.0, green: 0.52, blue: 0.1, alpha: 1.0)
]
let tagLine = CTLineCreateWithAttributedString(NSAttributedString(string: "EDWARD WESTHOFF · CLINIC MASTER", attributes: tagAttrs))
ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 54)
CTLineDraw(tagLine, ctx)

// Subtag
let subtagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 20, weight: .bold),
    .foregroundColor: NSColor(white: 0.85, alpha: 1.0)
]
let subtagLine = CTLineCreateWithAttributedString(NSAttributedString(string: "VITALITEIT & TOPSFEER", attributes: subtagAttrs))
ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 16)
CTLineDraw(subtagLine, ctx)

// Titel
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 50, weight: .heavy),
    .foregroundColor: NSColor.white
]
let titleLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Schaken op topsnelheid!", attributes: titleAttrs))
ctx.textPosition = CGPoint(x: 56, y: 330)
CTLineDraw(titleLine, ctx)

// Ondertitel (ZONDER voormalig topspeler!)
let subAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
    .foregroundColor: NSColor(white: 0.94, alpha: 1.0)
]
let subLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Tricks, effectballen & topsportvitaliteit met Edward!", attributes: subAttrs))
ctx.textPosition = CGPoint(x: 56, y: 260)
CTLineDraw(subLine, ctx)

// CTA
let ctaAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 24, weight: .bold),
    .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
]
let ctaLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Inclusief professionele clinic ➔ ttclinics.nl", attributes: ctaAttrs))
ctx.textPosition = CGPoint(x: 56, y: 195)
CTLineDraw(ctaLine, ctx)

ctx.restoreGState()

// Progress bar
ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: 350, height: 10))

if let outImg = ctx.makeImage() {
    let rep = NSBitmapImageRep(cgImage: outImg)
    let data = rep.representation(using: .jpeg, properties: [:])
    try? data?.write(to: URL(fileURLWithPath: "images/test_cutout_corner.jpg"))
    print("✓ test_cutout_corner.jpg gerenderd!")
}
