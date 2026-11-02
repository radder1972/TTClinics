import Foundation
import AVFoundation
import AppKit

let videoURL = URL(fileURLWithPath: "video/ttclinics-promo-9x16.mp4")
let asset = AVURLAsset(url: videoURL)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.maximumSize = CGSize(width: 540, height: 960)

let times: [Double] = [2.0, 9.0, 15.0, 24.0, 32.0]
for (idx, t) in times.enumerated() {
    let cmTime = CMTime(seconds: t, preferredTimescale: 600)
    if let cgImage = try? generator.copyCGImage(at: cmTime, actualTime: nil) {
        let rep = NSBitmapImageRep(cgImage: cgImage)
        if let data = rep.representation(using: .jpeg, properties: [:]) {
            let outPath = "images/promo-preview-\(idx+1).jpg"
            try? data.write(to: URL(fileURLWithPath: outPath))
            print("✓ Saved \(outPath) at \(t)s")
        }
    }
}
