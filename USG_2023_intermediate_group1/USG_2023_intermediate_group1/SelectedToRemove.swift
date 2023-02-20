//
//  SelectedToRemove.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/20.
//

import Foundation
import SwiftUI

struct SelectedToRemove: ViewModifier {
    
    @Binding var rmMovies: Set<String>
    @State var tap = false {
        didSet{
            if oldValue == true {
                rmMovies.remove(_id)
            } else {
                rmMovies.insert(_id)
            }
            print(rmMovies)
        }
    }
    @State var num = 0
    let _id: String
    
    func body(content: Content) -> some View {
        ZStack{
            /*
            if removes && tap {
                VStack{}.onAppear(){
                    for mov in 0..<rmMovies.count {
                        if rmMovies[mov]._id == _id {
                            rmMovies.remove(at: mov)
                            break
                        }
                    }
                    removes = false
                }
            }*/
            content
                .onTapGesture {
                    self.tap = true
                }
            if tap {
                ZStack{
                    Rectangle()
                        .cornerRadius(10)
                        .background(.thinMaterial)
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                }
                .onTapGesture {
                    self.tap = false
                }
            }
            
        }
    }
}
extension View {
    func itemSelect(rmMovie: Binding<Set<String>>, _id: String) -> some View {
        self.modifier(SelectedToRemove(rmMovies: rmMovie, _id: _id))
    }
}
