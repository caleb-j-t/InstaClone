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
    
    case Original = 0
    case Sepia = 1
    case Mono = 2
    case Darken = 3
    case Flip = 4
    case BlackWhite = 5
    case Hipster = 6
    case Vignette = 7
    
    
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
