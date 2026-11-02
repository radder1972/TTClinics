import Foundation
import AVFoundation
import AppKit
import CoreGraphics
import CoreText

// Configuratie voor 100% Fullscreen 9:16 Vertical Video (Instagram Reels / TikTok / YouTube Shorts)
let width = 1080
let height = 1920
let fps: Int32 = 30
let timeScale: Int32 = 600

struct PromoScene {
    let imagePath: String
    let iconPath: String
    let audioPath: String
    let tag: String
    let subtag: String
    let title: String
    let subtitle: String
    let cta: String
    let duration: Double
    let motionType: String // "zoom-in", "zoom-out", "pan-left", "pan-right", "pan-up"
}

let scenes: [PromoScene] = [
    PromoScene(
        imagePath: "images/hero-photo.jpg",
        iconPath: "images/icon-chart.png",
        audioPath: "audio/promo-1-hook.m4a",
        tag: "TT CLINICS · SPORTIEF BEDRIJFSUITJE",
        subtag: "ENERGIE & TEAMBUILDING",
        title: "Klaar voor méér energie?",
        subtitle: "Hét meest dynamische teamuitje van Nederland",
        cta: "Boek jullie team clinic ➔ ttclinics.nl",
        duration: 5.0,
        motionType: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/nieuws-edward-vmbo-kader-clinic.jpg",
        iconPath: "images/icon-heartbeat.png",
        audioPath: "audio/promo-2-edward.m4a",
        tag: "EDWARD WESTHOFF · CLINIC MASTER",
        subtag: "VITALITEIT & TOPSFEER",
        title: "Schaken op topsnelheid!",
        subtitle: "Tricks, effectballen & topsportvitaliteit",
        cta: "Inclusief professionele clinic ➔ ttclinics.nl",
        duration: 6.2,
        motionType: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/zaal-toernooi-opgeflufft.jpg",
        iconPath: "images/icon-location.png",
        audioPath: "audio/promo-3-zaal.m4a",
        tag: "DE LOCATIE · WEESP & OP KANTOOR",
        subtag: "THUISBASIS THE VICTORY",
        title: "Professionele zaal & sfeer",
        subtitle: "Bij The Victory in Weesp én op jullie locatie",
        cta: "Vaste clubzaal of op eigen locatie ➔ ttclinics.nl",
        duration: 6.2,
        motionType: "pan-right"
    ),
    PromoScene(
        imagePath: "images/wisseltrofee-medailles.jpg",
        iconPath: "images/icon-trophy.png",
        audioPath: "audio/promo-4-battle.m4a",
        tag: "COMPETITIE · COMPANY BATTLE",
        subtag: "OFFICIËLE WISSELTROFEE",
        title: "Strijd om de Wisseltrofee 🏆",
        subtitle: "Gezonde rivaliteit, toernooischema & medailles",
        cta: "Inclusief officiële trofee & medailles ➔ ttclinics.nl",
        duration: 6.8,
        motionType: "pan-up"
    ),
    PromoScene(
        imagePath: "images/blacklight-team-clinic.jpg",
        iconPath: "images/icon-shield.png",
        audioPath: "audio/promo-5-glow.m4a",
        tag: "GLOW IN THE DARK · BLACKLIGHT",
        subtag: "UNIEKE BELEVING IN HET DONKER",
        title: "Tafeltennis in het donker 🔮",
        subtitle: "UV-blacklight, fluor batjes & neon beats",
        cta: "Exclusief te boeken in Weesp ➔ ttclinics.nl",
        duration: 5.2,
        motionType: "zoom-out"
    ),
    PromoScene(
        imagePath: "images/zaal-bar-kantine.jpg",
        iconPath: "images/icon-phone.png",
        audioPath: "audio/promo-6-outro.m4a",
        tag: "RESERVEER DIRECT · TTCLINICS.NL",
        subtag: "VRAAG EEN VRIJBLIJVEND VOORSTEL AAN",
        title: "Boek jouw Team Clinic! 🏓",
        subtitle: "Gezellig borrelen · Bel 06-11618060",
        cta: "Direct datum reserveren ➔ ttclinics.nl",
        duration: 7.2,
        motionType: "zoom-in"
    )
]

let totalDuration = scenes.reduce(0.0) { $0 + $1.duration }
let totalFrames = Int(totalDuration * Double(fps))

print("🎬 Start Renderen van TT Clinics Promotievideo (Uitgesneden hoek & Eye of the Tiger beat)")
print("   Formaat: \(width)x\(height) Full HD | Duur: \(String(format: "%.2f", totalDuration))s (\(totalFrames) frames)")
print("   Stem: Roos (ElevenLabs Nederlands - Edward = Clinic Master & Coach)")

// 1. Laad beelden
var loadedImages: [CGImage] = []
var loadedIcons: [CGImage] = []

for sc in scenes {
    guard let nsImage = NSImage(contentsOfFile: sc.imagePath),
          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("❌ Kan afbeelding niet laden: \(sc.imagePath)")
        exit(1)
    }
    loadedImages.append(cgImage)

    guard let nsIcon = NSImage(contentsOfFile: sc.iconPath),
          let cgIcon = nsIcon.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("❌ Kan icoon niet laden: \(sc.iconPath)")
        exit(1)
    }
    loadedIcons.append(cgIcon)
}

guard let nsLogo = NSImage(contentsOfFile: "images/logo-lockup-header.png"),
      let cgLogo = nsLogo.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("❌ Kan logo niet laden")
    exit(1)
}

// Extra camerahoeken voor dynamische multi-angle zaaltour in Scène 3
guard let nsZaal1 = NSImage(contentsOfFile: "images/zaal-toernooi-opgeflufft.jpg"),
      let cgZaal1 = nsZaal1.cgImage(forProposedRect: nil, context: nil, hints: nil),
      let nsZaal2 = NSImage(contentsOfFile: "images/zaal-perspectief-opgeflufft.jpg"),
      let cgZaal2 = nsZaal2.cgImage(forProposedRect: nil, context: nil, hints: nil),
      let nsZaal3 = NSImage(contentsOfFile: "images/zaal-opgeflufft.jpg"),
      let cgZaal3 = nsZaal3.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("❌ Kan extra zaal hoeken niet laden")
    exit(1)
}

// 2. Video Writer opzetten
let rawVideoURL = URL(fileURLWithPath: "video/temp_raw_promo.mp4")
try? FileManager.default.removeItem(at: rawVideoURL)

let videoWriter = try AVAssetWriter(outputURL: rawVideoURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 6_500_000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
    ]
]

let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
writerInput.expectsMediaDataInRealTime = false

let pixelBufferAttributes: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height,
    kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
]

let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: pixelBufferAttributes)

videoWriter.add(writerInput)
videoWriter.startWriting()
videoWriter.startSession(atSourceTime: .zero)

func createPixelBuffer(pool: CVPixelBufferPool?) -> CVPixelBuffer? {
    var buffer: CVPixelBuffer?
    if let pool = pool {
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    } else {
        CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32ARGB, pixelBufferAttributes as CFDictionary, &buffer)
    }
    return buffer
}

var sceneStartTimes: [Double] = []
var cumTime: Double = 0.0
for sc in scenes {
    sceneStartTimes.append(cumTime)
    cumTime += sc.duration
}

let colorSpace = CGColorSpaceCreateDeviceRGB()

let bottomColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.90),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.60),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.20),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let bottomLocs: [CGFloat] = [0.0, 0.40, 0.75, 1.0]
let bottomGradient = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: bottomLocs)!

// Zachte lichte achtergrond-gloed voor het originele logo (zonder box)
let glowColors = [
    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.85),
    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.45),
    CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
] as CFArray
let glowLocs: [CGFloat] = [0.0, 0.45, 1.0]
let glowGradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocs)!

var frameIndex = 0

while frameIndex < totalFrames {
    if !writerInput.isReadyForMoreMediaData {
        usleep(6_000)
        continue
    }

    let currentTime = Double(frameIndex) / Double(fps)
    
    var activeSceneIdx = scenes.count - 1
    for i in 0..<scenes.count {
        let start = sceneStartTimes[i]
        let end = (i < scenes.count - 1) ? sceneStartTimes[i+1] : totalDuration
        if currentTime >= start && currentTime < end {
            activeSceneIdx = i
            break
        }
    }

    let currentScene = scenes[activeSceneIdx]
    let sceneStart = sceneStartTimes[activeSceneIdx]
    let timeInScene = currentTime - sceneStart
    let sceneProgress = min(1.0, max(0.0, timeInScene / currentScene.duration))

    guard let pixelBuffer = createPixelBuffer(pool: adaptor.pixelBufferPool) else {
        print("Kon pixel buffer niet aanmaken")
        break
    }

    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    let pxData = CVPixelBufferGetBaseAddress(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

    guard let ctx = CGContext(
        data: pxData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    ) else {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        break
    }

    var currentImg = loadedImages[activeSceneIdx]
    let currentIcon = loadedIcons[activeSceneIdx]
    var imgOrigW = Double(currentImg.width)
    var imgOrigH = Double(currentImg.height)

    // A. 100% FULLSCREEN EDGE-TO-EDGE BEREKENING (GEEN ZWARTE BALKEN!)
    var motionZoom = 1.05
    var motionOffsetX = 0.0
    var motionOffsetY = 0.0

    if activeSceneIdx == 2 {
        // SCÈNE 3: DYNAMISCHE MULTI-ANGLE CAMERA TOUR DOOR DE CLUBZAAL (3 CAMERASTANDPUNTEN)
        // Duur: 6.2 seconden
        // Hoek 1 (0.0s - 2.1s): Centrale toernooilijn - dynamische dolly zoom naar voren over de tafels
        // Hoek 2 (2.1s - 4.15s): Perspectief opstelling richting bar met vloeiende tracking pan
        // Hoek 3 (4.15s - 6.2s): Groots arena perspectief met pull-back reveal van de speelvloer
        if timeInScene < 2.1 {
            currentImg = cgZaal1
            let p = timeInScene / 2.1
            motionZoom = 1.04 + (p * 0.12)
            motionOffsetY = -20.0 + (p * 40.0)
        } else if timeInScene < 4.15 {
            currentImg = cgZaal2
            let t = timeInScene - 2.1
            let p = t / 2.05
            motionZoom = 1.08 + (p * 0.04)
            motionOffsetX = -60.0 + (p * 120.0)
            motionOffsetY = 10.0
        } else {
            currentImg = cgZaal3
            let t = timeInScene - 4.15
            let p = t / 2.05
            motionZoom = 1.15 - (p * 0.10)
            motionOffsetY = 25.0 - (p * 50.0)
        }
        imgOrigW = Double(currentImg.width)
        imgOrigH = Double(currentImg.height)
    } else {
        switch currentScene.motionType {
        case "zoom-in":
            motionZoom = 1.04 + (sceneProgress * 0.11)
        case "zoom-out":
            motionZoom = 1.15 - (sceneProgress * 0.11)
        case "pan-right":
            motionZoom = 1.08
            motionOffsetX = -70.0 + (sceneProgress * 140.0)
        case "pan-left":
            motionZoom = 1.08
            motionOffsetX = 70.0 - (sceneProgress * 140.0)
        case "pan-up":
            motionZoom = 1.06
            motionOffsetY = -60.0 + (sceneProgress * 120.0)
        default:
            motionZoom = 1.05
        }
    }

    let baseScale = max(Double(width) / imgOrigW, Double(height) / imgOrigH)
    let finalScale = baseScale * motionZoom
    let drawW = imgOrigW * finalScale
    let drawH = imgOrigH * finalScale
    let drawX = (Double(width) - drawW) / 2.0 + motionOffsetX
    let drawY = (Double(height) - drawH) / 2.0 + motionOffsetY

    ctx.draw(currentImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))

    // Snelle energieke overgangsflits tussen camerastandpunten in scène 3
    if activeSceneIdx == 2 {
        let t1 = timeInScene - 2.1
        let t2 = timeInScene - 4.15
        if t1 >= 0 && t1 < 0.18 {
            let flashAlpha = (1.0 - (t1 / 0.18)) * 0.35
            ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(flashAlpha)))
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        } else if t2 >= 0 && t2 < 0.18 {
            let flashAlpha = (1.0 - (t2 / 0.18)) * 0.35
            ctx.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: CGFloat(flashAlpha)))
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }

        // Dynamische vliegende TT-bal in scène 3 (Hoek 1 over de speeltafels)
        if timeInScene >= 0.3 && timeInScene <= 1.4 {
            let bt = (timeInScene - 0.3) / 1.1
            let bx = 620.0 - (bt * 220.0)
            let bouncePhase = bt < 0.5 ? (bt / 0.5) : ((bt - 0.5) / 0.5)
            let arcHeight = 4.0 * bouncePhase * (1.0 - bouncePhase)
            let tableY = 820.0 - (bt * 140.0)
            let by = tableY + (arcHeight * 110.0)
            let ballSize = 22.0 + (bt * 32.0)

            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: 0), blur: 18, color: CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.85))
            ctx.setFillColor(CGColor(red: 1.0, green: 0.48, blue: 0.0, alpha: 0.95))
            ctx.fillEllipse(in: CGRect(x: bx, y: by, width: ballSize, height: ballSize))

            // Witte glans / 3D highlight
            ctx.setFillColor(CGColor(red: 1.0, green: 0.90, blue: 0.70, alpha: 0.90))
            ctx.fillEllipse(in: CGRect(x: bx + (ballSize * 0.25), y: by + (ballSize * 0.45), width: ballSize * 0.38, height: ballSize * 0.38))
            ctx.restoreGState()
        }
    }

    // B. VLOEIENDE SCHADUW-GRADIËNT VOOR TEKSTLEESBAARHEID ONDERAAN
    ctx.drawLinearGradient(bottomGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 740), options: [])

    // C. Vloeiende fade-in per scène (0.28s)
    let fadeDuration = 0.28
    if timeInScene < fadeDuration {
        let fadeAlpha = 1.0 - (timeInScene / fadeDuration)
        ctx.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(fadeAlpha * 0.75)))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }

    // D. TT CLINICS LOGO LINKSBOVEN MET GROTE ACHTERGROND SWOOSHES & BACKLIGHT GLOED
    let logoW = 500.0
    let logoH = logoW * (Double(cgLogo.height) / Double(cgLogo.width))
    let logoX = 56.0 // Strak uitgelijnd met de content & iconen links
    let logoY = 1730.0

    // 1. Zachte backlight-gloed gecentreerd achter het logo linksboven
    let glowCenter = CGPoint(x: logoX + (logoW * 0.45), y: logoY + (logoH * 0.45))
    ctx.drawRadialGradient(
        glowGradient,
        startCenter: glowCenter,
        startRadius: 0.0,
        endCenter: glowCenter,
        endRadius: 420.0,
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )

    // 2. Dynamische swooshes groot op de achtergrond die vanaf linksboven naar rechts schieten
    ctx.saveGState()
    let swooshX = 30.0
    let swooshY = 1675.0
    let swooshScale = 4.6

    ctx.translateBy(x: CGFloat(swooshX), y: CGFloat(swooshY))
    ctx.scaleBy(x: CGFloat(swooshScale), y: CGFloat(swooshScale))
    ctx.setShadow(offset: CGSize(width: 0, height: -4), blur: 18, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.55))
    ctx.setAlpha(0.72)

    // Oranje hoofdstreak (#FF6B00)
    let p1 = CGMutablePath()
    p1.move(to: CGPoint(x: 0, y: 82)); p1.addLine(to: CGPoint(x: 196, y: 8)); p1.addLine(to: CGPoint(x: 176, y: 30)); p1.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.addPath(p1); ctx.fillPath()

    // Lichtoranje highlight streak (#FF9A4D)
    let p2 = CGMutablePath()
    p2.move(to: CGPoint(x: 22, y: 98)); p2.addLine(to: CGPoint(x: 184, y: 44)); p2.addLine(to: CGPoint(x: 170, y: 56)); p2.closeSubpath()
    ctx.setFillColor(CGColor(red: 1.0, green: 0.60, blue: 0.30, alpha: 1.0))
    ctx.addPath(p2); ctx.fillPath()

    // Metallic zilver/witte streak (#E2E8F0)
    let p3 = CGMutablePath()
    p3.move(to: CGPoint(x: 8, y: 58)); p3.addLine(to: CGPoint(x: 150, y: 6)); p3.addLine(to: CGPoint(x: 136, y: 20)); p3.closeSubpath()
    ctx.setFillColor(CGColor(red: 0.88, green: 0.91, blue: 0.95, alpha: 1.0))
    ctx.addPath(p3); ctx.fillPath()

    ctx.restoreGState()

    // 3. Het originele TT Clinics logo LINKSBOVEN in VOLLE ORIGINELE KLEUR (GEEN BOX!)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 18, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.65))
    ctx.draw(cgLogo, in: CGRect(x: logoX, y: logoY, width: logoW, height: logoH))
    ctx.restoreGState()

    // E. EIGEN 2D ICOON & CONTENT ONDERAAN
    ctx.saveGState()

    let iconX = 56.0
    let iconY = 410.0
    let iconSize = 96.0

    // Teken het 2D icoon van de specifieke scène
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 6), blur: 18, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))
    ctx.draw(currentIcon, in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
    ctx.restoreGState()

    ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))

    // 1. Tag (oranje neon)
    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.52, blue: 0.1, alpha: 1.0)
    ]
    let tagStr = NSAttributedString(string: currentScene.tag.uppercased(), attributes: tagAttrs)
    let tagLine = CTLineCreateWithAttributedString(tagStr)
    ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 54)
    CTLineDraw(tagLine, ctx)

    // 2. Sub-tag (helder wit/lichtgrijs)
    let subtagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 20, weight: .bold),
        .foregroundColor: NSColor(white: 0.85, alpha: 1.0)
    ]
    let subtagStr = NSAttributedString(string: currentScene.subtag.uppercased(), attributes: subtagAttrs)
    let subtagLine = CTLineCreateWithAttributedString(subtagStr)
    ctx.textPosition = CGPoint(x: iconX + iconSize + 20, y: iconY + 16)
    CTLineDraw(subtagLine, ctx)

    // 3. Titel (Groot, Wit, Extra Vet)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 50, weight: .heavy),
        .foregroundColor: NSColor.white
    ]
    let titleStr = NSAttributedString(string: currentScene.title, attributes: titleAttrs)
    let titleLine = CTLineCreateWithAttributedString(titleStr)
    ctx.textPosition = CGPoint(x: 56, y: 330)
    CTLineDraw(titleLine, ctx)

    // 4. Gesproken ondertitel
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
        .foregroundColor: NSColor(white: 0.94, alpha: 1.0)
    ]
    let subStr = NSAttributedString(string: currentScene.subtitle, attributes: subAttrs)
    let subLine = CTLineCreateWithAttributedString(subStr)
    ctx.textPosition = CGPoint(x: 56, y: 260)
    CTLineDraw(subLine, ctx)

    // 5. CTA / Website link
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .bold),
        .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
    ]
    let ctaStr = NSAttributedString(string: currentScene.cta, attributes: ctaAttrs)
    let ctaLine = CTLineCreateWithAttributedString(ctaStr)
    ctx.textPosition = CGPoint(x: 56, y: 195)
    CTLineDraw(ctaLine, ctx)

    ctx.restoreGState()

    // F. VOORTGANGSBLAK ONDERAAN (TT Oranje, 10px hoog)
    let totalProgress = CGFloat(currentTime / totalDuration)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width) * totalProgress, height: 10))

    CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

    let frameTime = CMTime(value: Int64(frameIndex), timescale: fps)
    adaptor.append(pixelBuffer, withPresentationTime: frameTime)

    frameIndex += 1
    if frameIndex % (Int(fps) * 5) == 0 {
        let sec = frameIndex / Int(fps)
        print("  ⏳ Gerenderd: \(sec)s / \(Int(totalDuration))s...")
    }
}

writerInput.markAsFinished()

let group = DispatchGroup()
group.enter()
videoWriter.finishWriting {
    print("✓ Ruwe video gerenderd met uitgesneden hoek!")
    group.leave()
}
group.wait()

// 3. Audio & Video Muxen met ElevenLabs Roos spraak + Eye of the Tiger beat
print("🔊 Muxen van audio met ElevenLabs Nederlandse stem (Roos) en Eye of the Tiger beat...")

let composition = AVMutableComposition()
let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compVoiceTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compMusicTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

let videoAsset = AVURLAsset(url: rawVideoURL)
let videoTrack = videoAsset.tracks(withMediaType: .video).first!
try! compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)

// Voeg de 6 ElevenLabs spraakfragmenten in op hun exacte scènetijd
for (idx, sc) in scenes.enumerated() {
    let audioURL = URL(fileURLWithPath: sc.audioPath)
    if FileManager.default.fileExists(atPath: audioURL.path) {
        let scAsset = AVURLAsset(url: audioURL)
        if let scAudioTrack = scAsset.tracks(withMediaType: .audio).first {
            let insertTime = CMTime(seconds: sceneStartTimes[idx], preferredTimescale: timeScale)
            let scDur = min(scAsset.duration, CMTime(seconds: sc.duration, preferredTimescale: timeScale))
            try? compVoiceTrack.insertTimeRange(CMTimeRange(start: .zero, duration: scDur), of: scAudioTrack, at: insertTime)
        }
    }
}

// Achtergrondmuziek toevoegen (Eye of the Tiger beat)
let bgMusicURL = URL(fileURLWithPath: "audio/promo-bg-music.wav")
if FileManager.default.fileExists(atPath: bgMusicURL.path) {
    let bgAsset = AVURLAsset(url: bgMusicURL)
    if let bgTrack = bgAsset.tracks(withMediaType: .audio).first {
        let musicDuration = min(videoAsset.duration, bgAsset.duration)
        try? compMusicTrack.insertTimeRange(CMTimeRange(start: .zero, duration: musicDuration), of: bgTrack, at: .zero)
    }
}

// Audio Mix: Voice-over 100%, rock muziek op 22%
let audioMix = AVMutableAudioMix()
let musicParams = AVMutableAudioMixInputParameters(track: compMusicTrack)
musicParams.setVolume(0.22, at: .zero)

let voiceParams = AVMutableAudioMixInputParameters(track: compVoiceTrack)
voiceParams.setVolume(1.0, at: .zero)

audioMix.inputParameters = [voiceParams, musicParams]

let finalURL = URL(fileURLWithPath: "video/ttclinics-promo-9x16.mp4")
try? FileManager.default.removeItem(at: finalURL)

let finalExporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
finalExporter.outputURL = finalURL
finalExporter.outputFileType = .mp4
finalExporter.audioMix = audioMix

let muxGroup = DispatchGroup()
muxGroup.enter()
finalExporter.exportAsynchronously {
    print("Mux status:", finalExporter.status.rawValue)
    if let err = finalExporter.error {
        print("Mux error:", err)
    }
    muxGroup.leave()
}
muxGroup.wait()

// Schoon tijdelijke ruwe video op
try? FileManager.default.removeItem(at: rawVideoURL)

print("🎉 Voltooid! Definitieve 9:16 promotievideo opgeslagen als: \(finalURL.path)")
