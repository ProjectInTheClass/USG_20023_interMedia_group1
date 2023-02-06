//
//  ContentView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            getMov()
                .tabItem {
                    Image(systemName: "popcorn.fill")
                    Text("무비 장르 검색")
                }.tag(0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
