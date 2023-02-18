//
//  Swipe.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/18.
//

import SwiftUI

struct Swipe: ViewModifier {
    
    @State var offset = 0.0
    let geometry: GeometryProxy
    @State var open = false
    let maxoffset = -60.0
    
    @StateObject var user = User()
    @Binding var progress: Bool
    var itsMe = false
    var movieId: String = ""
    var commentId: String = ""
    
    func body(content: Content) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                //.frame(width: geometry.size.width - 65)
                .padding(.horizontal,20)
                .padding(.vertical, 6)
                .foregroundColor(itsMe ? .red : .secondary)
            Button {
                user.commentRemove(movieId: movieId, commentId: commentId)
                progress = true
            } label: {
                HStack{
                    Spacer()
                    Image(systemName:itsMe ? "trash.fill" : "trash.slash.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                        .foregroundColor(.white)
                        .padding(.horizontal,40)
                }
            }
            .frame(width: geometry.size.width)
            .disabled(itsMe ? false : true)

            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged{ gesture in
                            withAnimation {
                                if open {
                                    guard gesture.translation.width < maxoffset else {return}
                                    offset = gesture.translation.width
                                } else {
                                    guard gesture.translation.width < 0 else {return}
                                    offset = gesture.translation.width
                                }
                            }
                        }
                        .onEnded{ gesture in
                            withAnimation {
                                if open {
                                    offset = .zero
                                    open = false
                                } else {
                                    guard gesture.translation.width < 0 else {return}
                                    offset = maxoffset
                                    open = true
                                }
                            }
                        }
                )
            
        }
    }
}

extension View {
    func Swipes(geometry: GeometryProxy, progress: Binding<Bool>, itsMe: Bool = false, movieId: String, commentId: String) -> some View {
        self.modifier(Swipe(geometry: geometry, progress: progress, itsMe: itsMe, movieId: movieId, commentId: commentId))
    }
}
