import Foundation
import AVFoundation
import AppKit
import CoreGraphics
import CoreText

let width = 1920
let height = 1080
let fps: Int32 = 30
let timeScale: Int32 = 600

// Scènes en hun exacte tijden
struct SceneDef {
    let imagePath: String
    let tag: String
    let title: String
    let subtitle: String
    let duration: Double
}

let scenes: [SceneDef] = [
    SceneDef(
        imagePath: "images/story-1-woensdag.jpg",
        tag: "SCÈNE 1 · DE OORSPRONG",
        title: "Het begon in een bescheiden gymzaal",
        subtitle: "Sportshal De Meer · Woensdagochtend",
        duration: 15.91 + 0.8
    ),
    SceneDef(
        imagePath: "images/story-2-bettine.jpg",
        tag: "SCÈNE 2 · DE SAMENWERKING (GECENSUREERD)",
        title: "Edward & [Gecensureerd] slaan de handen ineen",
        subtitle: "Ontmoeting met een 10-voudig Kampioene",
        duration: 15.83 + 0.8
    ),
    SceneDef(
        imagePath: "images/story-3-concept.jpg",
        tag: "SCÈNE 3 · DE FORMULE",
        title: "Schaken op topsnelheid: Het TT Clinics concept",
        subtitle: "De Unieke Bedrijfsclinic",
        duration: 14.58 + 0.8
    ),
    SceneDef(
        imagePath: "images/story-4-lancering.jpg",
        tag: "SCÈNE 4 · DE OFFICIËLE LANCERING",
        title: "De geboorte van hét sportieve bedrijfsuitje",
        subtitle: "Trots gelanceerd voor vitale teams",
        duration: 13.87
    )
]

let totalDuration = scenes.reduce(0.0) { $0 + $1.duration }
let totalFrames = Int(totalDuration * Double(fps))

print("🎬 Start MP4 rendering: \(width)x\(height) @ \(fps)fps | Duur: \(String(format: "%.2f", totalDuration))s (\(totalFrames) frames)")

// 1. Laad afbeeldingen in geheugen
var loadedImages: [CGImage] = []
for sc in scenes {
    guard let nsImage = NSImage(contentsOfFile: sc.imagePath),
          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Kan afbeelding niet laden: \(sc.imagePath)")
        exit(1)
    }
    loadedImages.append(cgImage)
}

// 2. Video Writer opzetten (tijdelijk zonder audio)
let rawVideoURL = URL(fileURLWithPath: "video/temp_video.mp4")
try? FileManager.default.removeItem(at: rawVideoURL)

let videoWriter = try AVAssetWriter(outputURL: rawVideoURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 2_500_000,
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

// Helper om pixel buffer te maken
func createPixelBuffer(pool: CVPixelBufferPool?) -> CVPixelBuffer? {
    var buffer: CVPixelBuffer?
    if let pool = pool {
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
    } else {
        CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_32ARGB, pixelBufferAttributes as CFDictionary, &buffer)
    }
    return buffer
}

// Bereken starttijd per scène
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
        usleep(10_000)
        continue
    }

    let currentTime = Double(frameIndex) / Double(fps)
    
    // Bepaal welke scène actief is
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

    // Pixel Buffer voorbereiden
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

    // Achtergrond zwart
    ctx.setFillColor(CGColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0))
    ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

    // 1. Teken afbeelding met subtiele Ken Burns zoom (1.0 -> 1.08)
    let zoomFactor = 1.0 + (sceneProgress * 0.07)
    let imgW = Double(width) * zoomFactor
    let imgH = Double(height) * zoomFactor
    let offsetX = (Double(width) - imgW) / 2.0
    let offsetY = (Double(height) - imgH) / 2.0
    let drawRect = CGRect(x: offsetX, y: offsetY, width: imgW, height: imgH)

    let currentImg = loadedImages[activeSceneIdx]
    ctx.draw(currentImg, in: drawRect)

    // Fade-in effect aan begin van elke scène (0.4s)
    let fadeDuration = 0.4
    if timeInScene < fadeDuration {
        let fadeAlpha = 1.0 - (timeInScene / fadeDuration)
        ctx.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: CGFloat(fadeAlpha)))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }

    // 2. Subtiele donkere gradient aan onderkant voor ondertiteling
    let gradientColors = [
        CGColor(red: 0, green: 0, blue: 0, alpha: 0.0),
        CGColor(red: 0, green: 0, blue: 0, alpha: 0.65),
        CGColor(red: 0, green: 0, blue: 0, alpha: 0.92)
    ] as CFArray
    let gradientLocations: [CGFloat] = [0.0, 0.4, 1.0]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: gradientLocations) {
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 280),
            end: CGPoint(x: 0, y: 0),
            options: []
        )
    }

    // 3. Tekst en branding tekenen
    // Top-left TT Clinics Watermerk
    let logoTag = "TT CLINICS"
    let logoAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .black),
        .foregroundColor: NSColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.95) // TT Orange
    ]
    let logoStr = NSAttributedString(string: logoTag, attributes: logoAttrs)
    let logoLine = CTLineCreateWithAttributedString(logoStr)
    ctx.textPosition = CGPoint(x: 80, y: Double(height) - 70)
    CTLineDraw(logoLine, ctx)

    // Tag (oranje pill tekst)
    let tagAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 20, weight: .bold),
        .foregroundColor: NSColor(red: 1.0, green: 0.55, blue: 0.1, alpha: 1.0)
    ]
    let tagStr = NSAttributedString(string: currentScene.tag, attributes: tagAttrs)
    let tagLine = CTLineCreateWithAttributedString(tagStr)
    ctx.textPosition = CGPoint(x: 80, y: 190)
    CTLineDraw(tagLine, ctx)

    // Titel (groot, wit, bold)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 42, weight: .heavy),
        .foregroundColor: NSColor.white
    ]
    let titleStr = NSAttributedString(string: currentScene.title, attributes: titleAttrs)
    let titleLine = CTLineCreateWithAttributedString(titleStr)
    ctx.textPosition = CGPoint(x: 80, y: 130)
    CTLineDraw(titleLine, ctx)

    // Subtitel / Jaar (lichtgrijs)
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 24, weight: .medium),
        .foregroundColor: NSColor(white: 0.85, alpha: 1.0)
    ]
    let subStr = NSAttributedString(string: currentScene.subtitle, attributes: subAttrs)
    let subLine = CTLineCreateWithAttributedString(subStr)
    ctx.textPosition = CGPoint(x: 80, y: 85)
    CTLineDraw(subLine, ctx)

    // Voortgangsbalk onderin (oranje streep)
    let totalProgress = CGFloat(currentTime / totalDuration)
    ctx.setFillColor(CGColor(red: 1.0, green: 0.42, blue: 0.0, alpha: 0.9))
    ctx.fill(CGRect(x: 0, y: 0, width: CGFloat(width) * totalProgress, height: 6))

    CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

    let frameTime = CMTime(value: Int64(frameIndex), timescale: fps)
    adaptor.append(pixelBuffer, withPresentationTime: frameTime)

    frameIndex += 1
    if frameIndex % (Int(fps) * 10) == 0 {
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

// 3. Audio & Video Muxen naar definitieve MP4
print("🔊 Muxen van audio (\(scenes.count) scènes) en video...")
let finalURL = URL(fileURLWithPath: "video/ttclinics-ontstaan.mp4")
try? FileManager.default.removeItem(at: finalURL)

let composition = AVMutableComposition()

let videoAsset = AVURLAsset(url: rawVideoURL)
let audioAsset = AVURLAsset(url: URL(fileURLWithPath: "video/master_audio.m4a"))

let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

let videoTrack = videoAsset.tracks(withMediaType: .video).first!
let audioTrack = audioAsset.tracks(withMediaType: .audio).first!

let vDuration = videoAsset.duration
let aDuration = audioAsset.duration
let finalDuration = CMTimeMinimum(vDuration, aDuration)

try! compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: finalDuration), of: videoTrack, at: .zero)
try! compAudioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: finalDuration), of: audioTrack, at: .zero)

let finalExporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
finalExporter.outputURL = finalURL
finalExporter.outputFileType = .mp4

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

print("🎉 Voltooid! Definitieve MP4 video opgeslagen als: \(finalURL.path)")
