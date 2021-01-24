//
//  ARCamera+Extension.swift
//  Face
//
//  Created by Kristina Gelzinyte on 1/24/21.
//

import ARKit

extension ARCamera {
    
    var fieldOfView: CGSize {
        let xFovDegrees = 2 * atan(imageResolution.width / (2 * CGFloat(intrinsics[0, 0]))) * 180 / CGFloat.pi
        let yFovDegrees = 2 * atan(imageResolution.height / (2 * CGFloat(intrinsics[1, 1]))) * 180 / CGFloat.pi
        return CGSize(width: xFovDegrees, height: yFovDegrees)
    }
}
