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

// 1. FULLSCREEN EDGE-TO-EDGE (Geen zwarte balken!)
let scale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * 1.05
let drawW = imgOrigW * scale
let drawH = imgOrigH * scale
let drawX = (Double(width) - drawW) / 2.0
let drawY = (Double(height) - drawH) / 2.0

ctx.draw(cgImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))

// 2. Subtiele vloeiende gradiënten voor tekstleesbaarheid (geen harde balken!)
let bottomColors = [
    CGColor(red: 0, green: 0, blue: 0, alpha: 0.85),
    CGColor(red: 0, green: 0, blue: 0, alpha: 0.45),
    CGColor(red: 0, green: 0, blue: 0, alpha: 0.0)
] as CFArray
let bottomLocs: [CGFloat] = [0.0, 0.55, 1.0]
if let grad = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: bottomLocs) {
    ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 700), options: [])
}

let topColors = [
    CGColor(red: 0, green: 0, blue: 0, alpha: 0.65),
    CGColor(red: 0, green: 0, blue: 0, alpha: 0.0)
] as CFArray
let topLocs: [CGFloat] = [0.0, 1.0]
if let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: topLocs) {
    ctx.drawLinearGradient(topGrad, start: CGPoint(x: 0, y: 1920), end: CGPoint(x: 0, y: 1650), options: [])
}

// 3. Top Brand Pill
let pillRect = CGRect(x: 60, y: 1770, width: 420, height: 56)
let pillPath = CGPath(roundedRect: pillRect, cornerWidth: 28, cornerHeight: 28, transform: nil)
ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.92)) // TT Oranje
ctx.addPath(pillPath)
ctx.fillPath()

let pillAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 22, weight: .black),
    .foregroundColor: NSColor.white
]
let pillStr = NSAttributedString(string: "🏓  TT CLINICS  ·  WEESP", attributes: pillAttrs)
let pillLine = CTLineCreateWithAttributedString(pillStr)
ctx.textPosition = CGPoint(x: 88, y: 1790)
CTLineDraw(pillLine, ctx)

// 4. Content Text (Direct zwevend op de foto met schaduw)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))

// Tag
let tagAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 24, weight: .heavy),
    .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
]
let tagLine = CTLineCreateWithAttributedString(NSAttributedString(string: "DE LOCATIE · WEESP & KANTOOR", attributes: tagAttrs))
ctx.textPosition = CGPoint(x: 60, y: 460)
CTLineDraw(tagLine, ctx)

// Titel
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 52, weight: .black),
    .foregroundColor: NSColor.white
]
let titleLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Professionele zaal & topsfeer", attributes: titleAttrs))
ctx.textPosition = CGPoint(x: 60, y: 380)
CTLineDraw(titleLine, ctx)

// Subtitel (ElevenLabs Roos voiceover)
let subAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 30, weight: .semibold),
    .foregroundColor: NSColor(white: 0.95, alpha: 1.0)
]
let subLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Speel bij The Victory in Weesp óf op jullie kantoor!", attributes: subAttrs))
ctx.textPosition = CGPoint(x: 60, y: 310)
CTLineDraw(subLine, ctx)

// Website CTA
let ctaAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 26, weight: .bold),
    .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
]
let ctaLine = CTLineCreateWithAttributedString(NSAttributedString(string: "Vraag jouw clinic aan ➔ ttclinics.nl", attributes: ctaAttrs))
ctx.textPosition = CGPoint(x: 60, y: 230)
CTLineDraw(ctaLine, ctx)

ctx.restoreGState()

// Progress bar aan de onderkant
ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: 600, height: 10))

if let outImg = ctx.makeImage() {
    let rep = NSBitmapImageRep(cgImage: outImg)
    let data = rep.representation(using: .jpeg, properties: [:])
    try? data?.write(to: URL(fileURLWithPath: "images/test_frame.jpg"))
    print("✓ test_frame.jpg gerenderd!")
}
