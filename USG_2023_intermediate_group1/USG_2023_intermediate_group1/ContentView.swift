//
//  ContentView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/06.
// 홈

import SwiftUI

struct ContentView: View {
    
    enum SelectView {
        case Home
        case MyMovies
    }
    
    @State var selcetView: SelectView = .Home
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationStack{
                ZStack(alignment: .bottom){
                    TabView(selection: $selcetView){
                        MainView(geometry: geometry)
                            .tag(SelectView.Home)
                        MyMovie()
                            .tag(SelectView.MyMovies)
                    }
                    .toolbar(.hidden, for: .tabBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("My Netflix")
                                .font(.title)
                                .bold()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack{
                                NavigationLink {
                                    PostMovie()
                                } label: {
                                    Image(systemName: "rectangle.stack.fill.badge.plus")
                                }
                                NavigationLink {
                                    getMov() // 검색
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                }
                                NavigationLink {
                                    loginpage() // 프로필
                                } label: {
                                    Image(systemName: "person.fill")
                                }
                            }.tint(.white)
                        }
                    }
                    .preferredColorScheme(.dark)
                    HStack(spacing: 0){
                        Button {
                            selcetView = .Home
                        } label: {
                            VStack(spacing: 3){
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width/2,height: 20)
                                    .foregroundColor(selcetView == .Home ? .white : .secondary)
                                Text("홈")
                                    .font(.footnote)
                            }
                        }
                        Button {
                            selcetView = .MyMovies
                        } label: {
                            VStack(spacing: 3){
                                Image(systemName: "heart.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width/2,height: 20)
                                    .foregroundColor(selcetView == .MyMovies ? .white : .secondary)
                                Text("내가 찜한 콘텐츠")
                                    .font(.footnote)
                            }
                            .onAppear(){
                                
                            }
                        }
                    }
                    
                    .frame(width: geometry.size.width)
                    .tint(.white)
                    //.border(.gray)
                    //.padding(.top,5)
                    //.background(.thinMaterial)
                    //.buttonStyle(.borderedProminent)
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
