//
//  TopRoundedShape.swift
//  GimiFeedback
//
//  Created by 김민석 on 7/28/25.
//

import SwiftUI

struct TopRoundedShape: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom-left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(to: CGPoint(x: rect.minX + radius, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + radius),
                          control: CGPoint(x: rect.maxX, y: rect.minY))

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom-right
        path.closeSubpath()

        return path
    }
}
