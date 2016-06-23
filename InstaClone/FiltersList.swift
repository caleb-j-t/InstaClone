//
//  FiltersList.swift
//  InstaClone
//
//  Created by Mike Nancett on 6/21/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//
//


import Foundation
import CoreImage
import CoreFoundation


enum Filter: Int{
    
    case Original
    case Sepia
    case Mono
    case Darken
    case Flip
    case BlackWhite
    case Hipster
    case Vignette
    
    
    func names() -> String {
        switch self{
        case .Original: return "Original"
        case .Sepia: return "Sepia"
        case .Mono: return "Mono"
        case .Darken: return "Darken"
        case .Flip: return "Flip"
        case .BlackWhite: return "BlackWhite"
        case .Hipster: return "Hipster"
        case .Vignette: return "Vignette"
            
        }
    }
    
    func filters() -> CIFilter {
        switch self{
        case .Original: return CIFilter()
        case .Sepia: return CIFilter(name: "CISepiaTone")!
        case .Mono: return CIFilter(name: "CIPhotoEffectMono")!
        case .Darken: return CIFilter(name: "CISRGBToneCurveToLinear")!
        case .Flip: return CIFilter(name: "CIColorInvert")!
        case .BlackWhite: return CIFilter(name: "CIPhotoEffectMono")!
        case .Hipster: return CIFilter(name: "CIPhotoEffectProcess")!
        case .Vignette: return CIFilter(name: "CIVignette")!
        }
    }
    
}
