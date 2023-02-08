//
//  ContentView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/06.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            Text("지원님 뷰")
                .background(.black)
                .toolbar {
                    NavigationLink {
                        getMov()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    NavigationLink {
                        loginpage()
                    } label: {
                        Image(systemName: "person.fill")
                    }
                }
                .navigationTitle(Text("지원님 뷰"))
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
