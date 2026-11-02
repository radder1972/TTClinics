import Foundation
import AVFoundation
import AppKit
import CoreGraphics
import CoreText

// Configuratie voor 9:16 Vertical Video (Instagram Reels / TikTok / Shorts)
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
    let duration: Double
    let panDirection: String // "up", "down", "zoom-in", "zoom-out"
}

let scenes: [PromoScene] = [
    PromoScene(
        imagePath: "images/hero-photo.jpg",
        audioPath: "audio/promo-1-hook.m4a",
        tag: "TT CLINICS · HÉT SPORTIEVE BEDRIJFSUITJE",
        title: "Klaar voor méér energie?",
        subtitle: "Hét meest dynamische teamuitje van Nederland",
        duration: 5.17 + 0.6,
        panDirection: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/nieuws-edward-vmbo-kader-clinic.jpg",
        audioPath: "audio/promo-2-edward.m4a",
        tag: "EDWARD WESTHOFF · CLINIC MASTER",
        title: "Schaken op topsnelheid!",
        subtitle: "Tricks, effectballen & topsportvitaliteit",
        duration: 6.69 + 0.6,
        panDirection: "down"
    ),
    PromoScene(
        imagePath: "images/zaal-toernooi-opgeflufft.jpg",
        audioPath: "audio/promo-3-zaal.m4a",
        tag: "DE LOCATIE · WEESP & OP EIGEN KANTOOR",
        title: "Professionele zaal & topsfeer",
        subtitle: "Bij The Victory in Weesp én op jullie locatie",
        duration: 6.10 + 0.6,
        panDirection: "zoom-in"
    ),
    PromoScene(
        imagePath: "images/wisseltrofee-medailles.jpg",
        audioPath: "audio/promo-4-battle.m4a",
        tag: "COMPETITIE · COMPANY BATTLE",
        title: "Strijd om de Wisseltrofee 🏆",
        subtitle: "Gezonde rivaliteit, toernooischema & medailles",
        duration: 6.33 + 0.6,
        panDirection: "up"
    ),
    PromoScene(
        imagePath: "images/blacklight-team-clinic.jpg",
        audioPath: "audio/promo-5-glow.m4a",
        tag: "GLOW IN THE DARK · BLACKLIGHT",
        title: "Tafeltennis in het donker 🔮",
        subtitle: "UV-blacklight, fluor batjes & neon beats",
        duration: 4.38 + 0.6,
        panDirection: "zoom-out"
    ),
    PromoScene(
        imagePath: "images/zaal-bar-kantine.jpg",
        audioPath: "audio/promo-6-outro.m4a",
        tag: "RESERVEER DIRECT · TTCLINICS.NL",
        title: "Boek jouw Team Clinic! 🏓",
        subtitle: "Gezellig borrelen · Bel 06-11618060",
        duration: 5.88 + 1.2,
        panDirection: "zoom-in"
    )
]

let totalDuration = scenes.reduce(0.0) { $0 + $1.duration }
let totalFrames = Int(totalDuration * Double(fps))

print("🎬 Start Renderen van TT Clinics 9:16 Promo Video!")
print("   Formaat: \(width)x\(height) @ \(fps)fps | Duur: \(String(format: "%.2f", totalDuration))s (\(totalFrames) frames)")

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

// 2. Video Writer opzetten (tijdelijk zonder audio)
let rawVideoURL = URL(fileURLWithPath: "video/temp_promo_9x16.mp4")
try? FileManager.default.removeItem(at: rawVideoURL)

let videoWriter = try AVAssetWriter(outputURL: rawVideoURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 5_000_000,
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
var frameIndex = 0

while frameIndex < totalFrames {
    if !writerInput.isReadyForMoreMediaData {
        usleep(8_000)
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

    // A. Donkere achtergrond
    ctx.setFillColor(CGColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 1.0))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

    let currentImg = loadedImages[activeSceneIdx]
    let imgOrigW = Double(currentImg.width)
    let imgOrigH = Double(currentImg.height)

    // B. Ambient Bewegende Achtergrond (Groot & verduisterd voor bioscoop-sfeer)
    ctx.saveGState()
    let bgZoom = 1.15 + (sceneProgress * 0.06)
    let bgScale = max(Double(width) / imgOrigW, Double(height) / imgOrigH) * bgZoom
    let bgW = imgOrigW * bgScale
    let bgH = imgOrigH * bgScale
    let bgX = (Double(width) - bgW) / 2.0
    let bgY = (Double(height) - bgH) / 2.0
    ctx.draw(currentImg, in: CGRect(x: bgX, y: bgY, width: bgW, height: bgH))
    
    // Donkere overlay over achtergrond
    ctx.setFillColor(CGColor(red: 0.05, green: 0.07, blue: 0.10, alpha: 0.82))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.restoreGState()

    // C. Hoofd Focus Kaart (Scherpe afbeelding in het midden met Ken Burns beweging)
    ctx.saveGState()
    let cardMarginX = 64.0
    let cardW = Double(width) - (cardMarginX * 2.0) // 952px
    let cardH = 1080.0
    let cardY = 520.0
    let cardRect = CGRect(x: cardMarginX, y: cardY, width: cardW, height: cardH)

    // Schaduw achter kaart
    ctx.setShadow(offset: CGSize(width: 0, height: -16), blur: 32, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.6))
    
    // Afgerond masker voor de kaart
    let clipPath = CGPath(roundedRect: cardRect, cornerWidth: 32, cornerHeight: 32, transform: nil)
    ctx.addPath(clipPath)
    ctx.clip()

    // Ken Burns animatie binnen de kaart
    var innerZoom = 1.0
    var panY = 0.0
    switch currentScene.panDirection {
    case "zoom-in":
        innerZoom = 1.02 + (sceneProgress * 0.10)
    case "zoom-out":
        innerZoom = 1.12 - (sceneProgress * 0.08)
    case "up":
        innerZoom = 1.08
        panY = -40.0 + (sceneProgress * 80.0)
    case "down":
        innerZoom = 1.08
        panY = 40.0 - (sceneProgress * 80.0)
    default:
        innerZoom = 1.05
    }

    let scale = max(cardW / imgOrigW, cardH / imgOrigH) * innerZoom
    let drawW = imgOrigW * scale
    let drawH = imgOrigH * scale
    let drawX = cardRect.origin.x + (cardW - drawW) / 2.0
    let drawY = cardRect.origin.y + (cardH - drawH) / 2.0 + panY
    
    ctx.draw(currentImg, in: CGRect(x: drawX, y: drawY, width: drawW, height: drawH))
    ctx.restoreGState()

    // Oranje rand om de kaart
    ctx.saveGState()
    ctx.addPath(clipPath)
    ctx.setStrokeColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.75)) // TT Orange
    ctx.setLineWidth(4.0)
    ctx.strokePath()
    ctx.restoreGState()

    // D. Fade-in bij begin van de scène (0.35s)
    let fadeDuration = 0.35
    if timeInScene < fadeDuration {
        let fadeAlpha = 1.0 - (timeInScene / fadeDuration)
        ctx.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(fadeAlpha)))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }

    // E. Top Header & Watermark (Veilige zone bovenaan)
    // TT Clinics Brand Badge (Rechtsboven)
    let topBrandRect = CGRect(x: 64, y: Double(height) - 180, width: Double(width) - 128, height: 72)
    let topPillPath = CGPath(roundedRect: topBrandRect, cornerWidth: 36, cornerHeight: 36, transform: nil)
    ctx.setFillColor(CGColor(red: 0.08, green: 0.11, blue: 0.16, alpha: 0.85))
    ctx.addPath(topPillPath)
    ctx.fillPath()
    ctx.setStrokeColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.5))
    ctx.setLineWidth(2.0)
    ctx.addPath(topPillPath)
    ctx.strokePath()

    // TT Clinics tekst in top badge
    let topAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 26, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
    ]
    let topStr = NSAttributedString(string: "🏓  TT CLINICS  ·  HÉT SPORTIEVE BEDRIJFSUITJE", attributes: topAttrs)
    let topLine = CTLineCreateWithAttributedString(topStr)
    ctx.textPosition = CGPoint(x: 100, y: Double(height) - 146)
    CTLineDraw(topLine, ctx)

    // F. Bottom Subtitle & Caption Card (Glazen kaart onderaan met dynamische tekst)
    let bottomCardRect = CGRect(x: 64, y: 110, width: Double(width) - 128, height: 350)
    let bottomCardPath = CGPath(roundedRect: bottomCardRect, cornerWidth: 28, cornerHeight: 28, transform: nil)
    
    // Kaart achtergrond (donker glas)
    ctx.setFillColor(CGColor(red: 0.06, green: 0.09, blue: 0.14, alpha: 0.92))
    ctx.addPath(bottomCardPath)
    ctx.fillPath()
    
    ctx.setStrokeColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.15))
    ctx.setLineWidth(2.0)
    ctx.addPath(bottomCardPath)
    ctx.strokePath()

    // Oranje accentbalkje links in de tekstkaart
    let accentRect = CGRect(x: 84, y: 150, width: 8, height: 260)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.fill(accentRect)

    // 1. Tag (oranje)
    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.52, blue: 0.1, alpha: 1.0)
    ]
    let tagStr = NSAttributedString(string: currentScene.tag.uppercased(), attributes: tagAttrs)
    let tagLine = CTLineCreateWithAttributedString(tagStr)
    ctx.textPosition = CGPoint(x: 110, y: 390)
    CTLineDraw(tagLine, ctx)

    // 2. Titel (Groot, Wit, Heavy Bold)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 46, weight: .heavy),
        .foregroundColor: NSColor.white
    ]
    let titleStr = NSAttributedString(string: currentScene.title, attributes: titleAttrs)
    let titleLine = CTLineCreateWithAttributedString(titleStr)
    ctx.textPosition = CGPoint(x: 110, y: 310)
    CTLineDraw(titleLine, ctx)

    // 3. Subtitel / Spraakondertiteling (Helder wit/grijs)
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 26, weight: .semibold),
        .foregroundColor: NSColor(white: 0.90, alpha: 1.0)
    ]
    let subStr = NSAttributedString(string: currentScene.subtitle, attributes: subAttrs)
    let subLine = CTLineCreateWithAttributedString(subStr)
    ctx.textPosition = CGPoint(x: 110, y: 230)
    CTLineDraw(subLine, ctx)

    // 4. Website / CTA footer in kaart
    let ctaAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .bold),
        .foregroundColor: NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0)
    ]
    let ctaStr = NSAttributedString(string: "Bekijk arrangementen & boek direct ➔ ttclinics.nl", attributes: ctaAttrs)
    let ctaLine = CTLineCreateWithAttributedString(ctaStr)
    ctx.textPosition = CGPoint(x: 110, y: 160)
    CTLineDraw(ctaLine, ctx)

    // G. Voortgangsbalk helemaal onderaan (TT Oranje)
    let totalProgress = CGFloat(currentTime / totalDuration)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 1.0))
    ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width) * totalProgress, height: 12))

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
    print("✓ Ruwe video gerenderd: \(rawVideoURL.path)")
    group.leave()
}
group.wait()

// 3. Audio & Video Muxen met gesproken voice-overs én achtergrondmuziek!
print("🔊 Muxen van audio (6 scènes voice-over + achtergrondmuziek)...")

let composition = AVMutableComposition()
let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compVoiceTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compMusicTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

// Voeg videobeelden toe
let videoAsset = AVURLAsset(url: rawVideoURL)
let videoTrack = videoAsset.tracks(withMediaType: .video).first!
try! compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoTrack, at: .zero)

// Voeg de 6 spraakfragmenten in op hun exacte scènetijd
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

// Voeg achtergrondmuziek toe met loop / trim
let bgMusicURL = URL(fileURLWithPath: "audio/promo-bg-music.wav")
if FileManager.default.fileExists(atPath: bgMusicURL.path) {
    let bgAsset = AVURLAsset(url: bgMusicURL)
    if let bgTrack = bgAsset.tracks(withMediaType: .audio).first {
        let musicDuration = min(videoAsset.duration, bgAsset.duration)
        try? compMusicTrack.insertTimeRange(CMTimeRange(start: .zero, duration: musicDuration), of: bgTrack, at: .zero)
    }
}

// Audio Mix: Voice-over op 100% volume, achtergrondmuziek subtiel op 20%
let audioMix = AVMutableAudioMix()
let musicParams = AVMutableAudioMixInputParameters(track: compMusicTrack)
musicParams.setVolume(0.20, at: .zero)

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

// Schoon tijdelijke bestanden op
try? FileManager.default.removeItem(at: rawVideoURL)

print("🎉 Voltooid! Definitieve 9:16 promotievideo opgeslagen als: \(finalURL.path)")
