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
    let audioPath: String
    let tag: String
    let title: String
    let subtitle: String
    let cta: String
    let duration: Double
    let motionType: String // "zoom-in", "zoom-out", "pan-left", "pan-right", "pan-up"
}

let scenes: [PromoScene] = [
    PromoScene(
        imagePath: "images/hero-photo.jpg",
        audioPath: "audio/promo-1-hook.m4a",
        tag: "TT CLINICS · HÉT SPORTIEVE BEDRIJFSUITJE",
        title: "Klaar voor méér energie?",
        subtitle: "Hét meest dynamische teamuitje van Nederland",
        cta: "Boek jullie team clinic ➔ ttclinics.nl",
        duration: 5.0,
        motionType: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/nieuws-edward-vmbo-kader-clinic.jpg",
        audioPath: "audio/promo-2-edward.m4a",
        tag: "EDWARD WESTHOFF · CLINIC MASTER",
        title: "Schaken op topsnelheid!",
        subtitle: "Tricks, effectballen & topsportvitaliteit",
        cta: "Inclusief professionele coaching ➔ ttclinics.nl",
        duration: 7.0,
        motionType: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/zaal-toernooi-opgeflufft.jpg",
        audioPath: "audio/promo-3-zaal.m4a",
        tag: "DE LOCATIE · WEESP & OP EIGEN KANTOOR",
        title: "Professionele zaal & sfeer",
        subtitle: "Bij The Victory in Weesp én op jullie locatie",
        cta: "Vaste clubzaal of op jullie kantoor ➔ ttclinics.nl",
        duration: 6.2,
        motionType: "pan-right"
    ),
    PromoScene(
        imagePath: "images/wisseltrofee-medailles.jpg",
        audioPath: "audio/promo-4-battle.m4a",
        tag: "COMPETITIE · COMPANY BATTLE",
        title: "Strijd om de Wisseltrofee 🏆",
        subtitle: "Gezonde rivaliteit, toernooischema & medailles",
        cta: "Inclusief officiële trofee & medailles ➔ ttclinics.nl",
        duration: 6.8,
        motionType: "pan-up"
    ),
    PromoScene(
        imagePath: "images/blacklight-team-clinic.jpg",
        audioPath: "audio/promo-5-glow.m4a",
        tag: "GLOW IN THE DARK · BLACKLIGHT",
        title: "Tafeltennis in het donker 🔮",
        subtitle: "UV-blacklight, fluor batjes & neon beats",
        cta: "Unieke blacklight beleving in Weesp ➔ ttclinics.nl",
        duration: 5.2,
        motionType: "zoom-out"
    ),
    PromoScene(
        imagePath: "images/zaal-bar-kantine.jpg",
        audioPath: "audio/promo-6-outro.m4a",
        tag: "RESERVEER DIRECT · TTCLINICS.NL",
        title: "Boek jouw Team Clinic! 🏓",
        subtitle: "Gezellig borrelen · Bel 06-11618060",
        cta: "Direct datum reserveren ➔ ttclinics.nl",
        duration: 7.2,
        motionType: "zoom-in"
    )
]

let totalDuration = scenes.reduce(0.0) { $0 + $1.duration }
let totalFrames = Int(totalDuration * Double(fps))

print("🎬 Start Renderen van 100% Full Bleed TT Clinics 9:16 Video (ZONDER zwarte balken!)")
print("   Formaat: \(width)x\(height) Full HD | Duur: \(String(format: "%.2f", totalDuration))s (\(totalFrames) frames)")
print("   Stem: Roos (ElevenLabs Nederlands)")

// 1. Laad beelden
var loadedImages: [CGImage] = []
for sc in scenes {
    guard let nsImage = NSImage(contentsOfFile: sc.imagePath),
          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("❌ Kan afbeelding niet laden: \(sc.imagePath)")
        exit(1)
    }
    loadedImages.append(cgImage)
}

// 2. Video Writer opzetten (MP4 H.264 High Quality)
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

// Gradiënten voor vloeiende tekstleesbaarheid zonder zwarte balken
let bottomColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.88),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.60),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.20),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let bottomLocs: [CGFloat] = [0.0, 0.40, 0.75, 1.0]
let bottomGradient = CGGradient(colorsSpace: colorSpace, colors: bottomColors, locations: bottomLocs)!

let topColors = [
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.70),
    CGColor(red: 0.02, green: 0.03, blue: 0.05, alpha: 0.0)
] as CFArray
let topLocs: [CGFloat] = [0.0, 1.0]
let topGradient = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: topLocs)!

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

    let currentImg = loadedImages[activeSceneIdx]
    let imgOrigW = Double(currentImg.width)
    let imgOrigH = Double(currentImg.height)

    // A. 100% FULLSCREEN EDGE-TO-EDGE BEREKENING (GEEN ZWARTE BALKEN!)
    // De basis-schaal zorgt dat de afbeelding ALTIJD het volledige scherm 1080x1920 dekt:
    let baseScale = max(Double(width) / imgOrigW, Double(height) / imgOrigH)
    
    var motionZoom = 1.05
    var motionOffsetX = 0.0
    var motionOffsetY = 0.0

    switch currentScene.motionType {
    case "zoom-in":
        // Subtiele push-in van 1.04 naar 1.15
        motionZoom = 1.04 + (sceneProgress * 0.11)
    case "zoom-out":
        // Pull-out van 1.15 naar 1.04
        motionZoom = 1.15 - (sceneProgress * 0.11)
    case "pan-right":
        // Vloeiende pan van links naar rechts
        motionZoom = 1.08
        motionOffsetX = -70.0 + (sceneProgress * 140.0)
    case "pan-left":
        // Vloeiende pan van rechts naar links
        motionZoom = 1.08
        motionOffsetX = 70.0 - (sceneProgress * 140.0)
    case "pan-up":
        // Vloeiende tilt omhoog (bijv. van onderkant trofee naar gouden top)
        motionZoom = 1.06
        motionOffsetY = -60.0 + (sceneProgress * 120.0)
    default:
        motionZoom = 1.05
    }

    let finalScale = baseScale * motionZoom
    let drawW = imgOrigW * finalScale
    let drawH = imgOrigH * finalScale
    let drawX = (Double(width) - drawW) / 2.0 + motionOffsetX
    let drawY = (Double(height) - drawH) / 2.0 + motionOffsetY

    // Teken afbeelding over het VOLLEDIGE scherm (0 tot 1080 breed, 0 tot 1920 hoog)
    ctx.draw(currentImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))

    // B. OVERLAY GRADIENTEN (Zachte vloeiende schaduwen, GEEN harde zwarte balken!)
    // Gradiënt aan de onderkant zodat witte tekst altijd 100% scherp en leesbaar is
    ctx.drawLinearGradient(bottomGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 720), options: [])
    // Gradiënt aan de bovenkant voor subtiel top-logo contrast
    ctx.drawLinearGradient(topGradient, start: CGPoint(x: 0, y: 1920), end: CGPoint(x: 0, y: 1650), options: [])

    // C. Vloeiende fade-in aan het begin van elke scène (0.28s)
    let fadeDuration = 0.28
    if timeInScene < fadeDuration {
        let fadeAlpha = 1.0 - (timeInScene / fadeDuration)
        ctx.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(fadeAlpha * 0.75)))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }

    // D. TOP BRANDING PILL (Subtiele compacte badge bovenaan)
    let topPillRect = CGRect(x: 56, y: 1775, width: 440, height: 58)
    let topPillPath = CGPath(roundedRect: topPillRect, cornerWidth: 29, cornerHeight: 29, transform: nil)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.94)) // TT Oranje
    ctx.addPath(topPillPath)
    ctx.fillPath()

    // Subtiele glansrand om de pil
    ctx.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.35))
    ctx.setLineWidth(1.5)
    ctx.addPath(topPillPath)
    ctx.strokePath()

    let topAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .black),
        .foregroundColor: NSColor.white
    ]
    let topStr = NSAttributedString(string: "🏓  TT CLINICS  ·  WEESP", attributes: topAttrs)
    let topLine = CTLineCreateWithAttributedString(topStr)
    ctx.textPosition = CGPoint(x: 84, y: 1795)
    CTLineDraw(topLine, ctx)

    // E. CONTENT ONDERTITELING (Rechtstreeks zwevend over het beeld met sterke schaduw!)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 4), blur: 16, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.85))

    // 1. Tag (Oranje neon accent)
    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.52, blue: 0.1, alpha: 1.0)
    ]
    let tagStr = NSAttributedString(string: currentScene.tag.uppercased(), attributes: tagAttrs)
    let tagLine = CTLineCreateWithAttributedString(tagStr)
    ctx.textPosition = CGPoint(x: 56, y: 470)
    CTLineDraw(tagLine, ctx)

    // 2. Titel (Groot, Wit, Extra Vet)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 52, weight: .heavy),
        .foregroundColor: NSColor.white
    ]
    let titleStr = NSAttributedString(string: currentScene.title, attributes: titleAttrs)
    let titleLine = CTLineCreateWithAttributedString(titleStr)
    ctx.textPosition = CGPoint(x: 56, y: 390)
    CTLineDraw(titleLine, ctx)

    // 3. Gesproken ondertitel (Helder wit met lichte grijstint)
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 30, weight: .semibold),
        .foregroundColor: NSColor(white: 0.94, alpha: 1.0)
    ]
    let subStr = NSAttributedString(string: currentScene.subtitle, attributes: subAttrs)
    let subLine = CTLineCreateWithAttributedString(subStr)
    ctx.textPosition = CGPoint(x: 56, y: 315)
    CTLineDraw(subLine, ctx)

    // 4. CTA / Website link
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .bold),
        .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
    ]
    let ctaStr = NSAttributedString(string: currentScene.cta, attributes: ctaAttrs)
    let ctaLine = CTLineCreateWithAttributedString(ctaStr)
    ctx.textPosition = CGPoint(x: 56, y: 240)
    CTLineDraw(ctaLine, ctx)

    ctx.restoreGState()

    // F. SUBTIELE PROGRESS BAR (Onderaan, TT Oranje, 10px hoog)
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
    print("✓ Ruwe video succesvol gerenderd (zonder zwarte balken)")
    group.leave()
}
group.wait()

// 3. Audio & Video Muxen met ElevenLabs Roos spraak + achtergrondmuziek
print("🔊 Muxen van audio met ElevenLabs Nederlandse stem (Roos) en muziek...")

let composition = AVMutableComposition()
let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compVoiceTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compMusicTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

// Videobeelden toevoegen
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

// Achtergrondmuziek toevoegen
let bgMusicURL = URL(fileURLWithPath: "audio/promo-bg-music.wav")
if FileManager.default.fileExists(atPath: bgMusicURL.path) {
    let bgAsset = AVURLAsset(url: bgMusicURL)
    if let bgTrack = bgAsset.tracks(withMediaType: .audio).first {
        let musicDuration = min(videoAsset.duration, bgAsset.duration)
        try? compMusicTrack.insertTimeRange(CMTimeRange(start: .zero, duration: musicDuration), of: bgTrack, at: .zero)
    }
}

// Audio Mix: Voice-over op 100% volume, achtergrondmuziek op 18% (subtiel & warm)
let audioMix = AVMutableAudioMix()
let musicParams = AVMutableAudioMixInputParameters(track: compMusicTrack)
musicParams.setVolume(0.18, at: .zero)

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

// Schoon tijdelijke ruwe videobestanden op
try? FileManager.default.removeItem(at: rawVideoURL)

print("🎉 Voltooid! Definitieve 9:16 promotievideo ZONDER zwarte balken opgeslagen als: \(finalURL.path)")
