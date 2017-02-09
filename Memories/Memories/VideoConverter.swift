//
//  VideoConverter.swift
//  Memories
//
//  Created by Felicity Johnson on 2/8/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

struct VideoConverter {
    var videoWriter: AVAssetWriter?
    static let outputSize = CGSize(width: 1920, height: 1080)
    
    static func convertToVideo(from images: [UIImage], progress: @escaping ((Progress) -> Void), success: @escaping ((URL) -> Void)) {
        
        var selectedImages = images
        print("COUNT: \(selectedImages.count)")
        let startTime = Date.timeIntervalSinceReferenceDate
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory: URL = urls.first else { print("error retrieving urls to convert into video"); return }
        
        let videoOutputURL = documentDirectory.appendingPathComponent("AssembledVideo.mov")
        
        if FileManager.default.fileExists(atPath: videoOutputURL.path) {
            do {
                try FileManager.default.removeItem(at: videoOutputURL)
            } catch {}
        }
        
        guard let videoWriter = try? AVAssetWriter(url: videoOutputURL, fileType: AVFileTypeQuickTimeMovie) else { print("error unwrapping videoWriter"); return }
        let outputSettings = [
            AVVideoCodecKey : AVVideoCodecH264,
            AVVideoWidthKey : NSNumber(value: Float(outputSize.width)),
            AVVideoHeightKey : NSNumber(value: Float(outputSize.height))
            ] as [String : Any]
        
        guard videoWriter.canApply(outputSettings: outputSettings, forMediaType: AVMediaTypeVideo) else { print("error applying output settings to video"); return }
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        
        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(integerLiteral: Int(kCMPixelFormat_32ARGB)),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))
        ]
        
        let pixelBufferAdopter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        assert(videoWriter.canAdd(videoWriterInput))
        videoWriter.add(videoWriterInput)
        
        if videoWriter.startWriting() {
            videoWriter.startSession(atSourceTime: kCMTimeZero)
            assert(pixelBufferAdopter.pixelBufferPool != nil)
            
            videoWriterInput.requestMediaDataWhenReady(on: .main, using: {
                let fps: Int32 = 1
                let frameDuration = CMTime(value: 1, timescale: fps)
                let currentProgress = Progress(totalUnitCount: Int64(images.count))
                
                var frameCount = 0
                while !selectedImages.isEmpty {
                    if videoWriterInput.isReadyForMoreMediaData {
                        let nextPhoto = selectedImages.remove(at: 0)
                        let lastFrameTime = CMTime(value: CMTimeValue(frameCount), timescale: fps)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        
                        print("nextPhoto: \(nextPhoto.size)")
                        
                        
                        if !self.appendPixelBufferForImage(image: nextPhoto, pixelBufferAdaptor: pixelBufferAdopter, presentationTime: presentationTime) {
                            print("ERROR APPENDING PIXEL BUFFER IMAGE")
                        }
                        
                        frameCount += 1
                        currentProgress.completedUnitCount = Int64(frameCount)
                        progress(currentProgress)
                    }
                }
                
                let endTime = Date.timeIntervalSinceReferenceDate
                let elapsedTime: TimeInterval = endTime - startTime
                
                print("Elapsed time: \(elapsedTime)")
                
                videoWriterInput.markAsFinished()
                videoWriter.finishWriting(completionHandler: {
                    success(videoOutputURL)
                    print("Success in creating videoOutputURL")
                })
            })
            
        }
    }
    
    static func appendPixelBufferForImage(image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = true
        var pixelBuffer: CVPixelBuffer? = nil
        let options: [NSObject : AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey : true as AnyObject,
            kCVPixelBufferCGBitmapContextCompatibilityKey : true as AnyObject
        ]
        
        let status: CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        if let pixelBuffer = pixelBuffer, status == 0 {
            let managedPixelBuffer = pixelBuffer
            print("Widthhhh \(image.size.width)")
            print("Heighttt \(image.size.height)")
            
            guard let pic = image.cgImage else { print("Error casting image as cgImage"); return false }
            pixelBufferFromImage(image: pic, pxBuffer: managedPixelBuffer, size: CGSize(width: image.size.width, height: image.size.height))
            appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
        return appendSucceeded
    }
    
    static func pixelBufferFromImage(image: CGImage, pxBuffer: CVPixelBuffer, size: CGSize) {
        CVPixelBufferLockBaseAddress(pxBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pxData = CVPixelBufferGetBaseAddress(pxBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxData, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let unwrappedContext = context else { print("Error unwrapping context in VideoView"); return }
        unwrappedContext.concatenate(CGAffineTransform(rotationAngle: 0))
        unwrappedContext.draw(image, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        CVPixelBufferUnlockBaseAddress(pxBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
}
