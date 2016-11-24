//
//  TimeLapseBuilder.swift
//  ColorPlayhouse
//
//  Created by Bruna Aleixo on 11/17/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import AVFoundation
import UIKit

let kErrorDomain = "TimeLapseBuilder"
let kFailedToStartAssetWriterError = 0
let kFailedToAppendPixelBufferError = 1

class TimeLapseBuilder: NSObject {
    let photoURLs: [String]
    var videoWriter: AVAssetWriter?
    
    init(photoURLs: [String]) {
        self.photoURLs = photoURLs
    }
    
    func build(progress: @escaping ((Progress) -> Void), success: @escaping ((NSURL) -> Void), failure: ((NSError) -> Void)) {
        let screenSize: CGRect = UIScreen.main.bounds
        
        let inputSize = CGSize(width: screenSize.width, height: screenSize.height)
        let outputSize = CGSize(width: screenSize.width, height: screenSize.height)
        var error: NSError?
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as NSString
        let videoOutputURL = NSURL(fileURLWithPath: documentsPath.appendingPathComponent("AssembledVideo.mov"))
        
        do {
            try FileManager.default.removeItem(at: videoOutputURL as URL)
        } catch {}
        
        do {
            try videoWriter = AVAssetWriter(outputURL: videoOutputURL as URL, fileType: AVFileTypeQuickTimeMovie)
        } catch let writerError as NSError {
            error = writerError
            videoWriter = nil
        }
        
        if let videoWriter = videoWriter {
            let videoSettings: [String : AnyObject] = [
                AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey  : outputSize.width as AnyObject,
                AVVideoHeightKey : outputSize.height as AnyObject
                //AVVideoCompressionPropertiesKey : [
                //          AVVideoAverageBitRateKey : NSInteger(1000000),
                //          AVVideoMaxKeyFrameIntervalKey : NSInteger(16) as AnyObject,
                //          AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                //] as AnyObject
            ]
            
            
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            videoWriterInput.expectsMediaDataInRealTime = true
            
            let sourceBufferAttributes = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                (kCVPixelBufferWidthKey as String): Float(inputSize.width),
                (kCVPixelBufferHeightKey as String): Float(inputSize.height)] as [String : Any]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: sourceBufferAttributes
            )
            
            assert(videoWriter.canAdd(videoWriterInput))
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: kCMTimeZero)
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                let media_queue = DispatchQueue(label: "mediaInputQueue")
                
                var frameCount: Int64 = 0
                var remainingPhotoURLs = [String](self.photoURLs)
                
                videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
                    let fps: Int32 = 5
                    let frameDuration = CMTimeMake(1, fps)
                    let currentProgress = Progress(totalUnitCount: Int64(self.photoURLs.count))
                    
                    
                    while (videoWriterInput.isReadyForMoreMediaData && !remainingPhotoURLs.isEmpty) {
                        let nextPhotoURL = remainingPhotoURLs.remove(at: 0)
                        let lastFrameTime = CMTimeMake(frameCount, fps)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        
                        
                        if !self.appendPixelBufferForImageAtURL(url: nextPhotoURL, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                            error = NSError(
                                domain: kErrorDomain,
                                code: kFailedToAppendPixelBufferError,
                                userInfo: [
                                    "description": "AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer",
                                    "rawError": videoWriter.error
                                ]
                            )
                            
                            break
                        }
                        
                        
                        frameCount += 1
                        
                        currentProgress.completedUnitCount = frameCount
                        progress(currentProgress)
                    }
                    
                    if remainingPhotoURLs.isEmpty {
                        videoWriterInput.markAsFinished()
                        videoWriter.finishWriting { () -> Void in
                            if error == nil {
                                success(videoOutputURL)
                            }
                            
                            self.videoWriter = nil
                        }
                    }
                    
                })
            } else {
                error = NSError(
                    domain: kErrorDomain,
                    code: kFailedToStartAssetWriterError,
                    userInfo: ["description": "AVAssetWriter failed to start writing"]
                )
            }
        }
        
        if let error = error {
            failure(error)
        }
    }
    
    func appendPixelBufferForImageAtURL(url: String, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            if let url = NSURL(string: url),
                let imageData = NSData(contentsOf: url as URL),
                let image = UIImage(data: imageData as Data),
                let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                let pixelBuffer = pixelBufferPointer.pointee
                
                if pixelBuffer != nil && status == 0 {
                    fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer!)
                    
                    appendSucceeded = pixelBufferAdaptor.append(
                        pixelBuffer!,
                        withPresentationTime: presentationTime
                    )
                    
                    pixelBufferPointer.deinitialize()
                } else {
                    NSLog("error: Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.deallocate(capacity: 1)
            }
        }
        
        return appendSucceeded
    }
    
    func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context?.draw(image.cgImage!, in: rect)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
}
