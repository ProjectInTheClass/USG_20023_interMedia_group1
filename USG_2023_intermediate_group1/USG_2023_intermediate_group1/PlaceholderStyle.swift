//
//  PlaceholderStyle.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2022/12/27.
//. placeholder 색 변화하기 위한 구조체

import SwiftUI
public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 5)
            }
            content
                .padding(5.0)
        }
    }
}
