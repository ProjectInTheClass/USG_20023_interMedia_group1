//
//  ContentView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/06.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var movieFunction = MovieFunction()
    
    @State var RandomGenre = Set<String>()
    @State var GenreRArray = [String]()
    @State var movieMain: Movie = Movie(title: "", _id: "", image: "", genre: [])
    
    var body: some View {
        GeometryReader{ geometry in
            NavigationStack{
                ScrollView{
                    if movieFunction.allGenreSuccess {
                        VStack{}.onAppear(){
                            let response = movieFunction.genreResponse!
                            while RandomGenre.count != 6 {
                                let str = response.data.randomElement()!.trimmingCharacters(in: ["\n"])
                                RandomGenre.insert(str)
                            }
                            GenreRArray.append(contentsOf: Array(RandomGenre))
                            movieFunction.allGenreSuccess = false
                        }
                    }
                    if !GenreRArray.isEmpty {
                        ZStack(alignment: .bottom){
                            HomeRecommandMovie(genre: GenreRArray.first == "SF" ? GenreRArray.last : GenreRArray.first, movie: $movieMain, geometry: geometry)
                                .clipShape(RoundedRectangle(cornerRadius: 20).size(width: geometry.size.width - 40, height: (geometry.size.width - 40) * 5/4))
                                .shadow(color: .black.opacity(1) ,radius: 10)
                                .padding(.horizontal,20)
                                .padding(.bottom, -40)
                                .padding(.top, 10)
                            VStack{
                                Text(movieMain.title)
                                    .bold()
                                    .font(.system(size: 45))
                                HStack{
                                    ForEach(movieMain.genre , id: \.self){ genre in
                                        if movieMain.genre.last == genre {
                                            Text(genre.trimmingCharacters(in: ["\n"]))
                                        } else {
                                            Text(genre.trimmingCharacters(in: ["\n"])+" ·")
                                        }
                                    }
                                }
                                Text("\n 지금 바로 시청하세요!\n")
                            }
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width - 40,height: 200)
                        }
                        ForEach(GenreRArray, id: \.self){ genre in
                            GenreStack(inputs: genre)
                        }
                    }
                }
                .background(.linearGradient(colors: [.black, .indigo.opacity(0.5)], startPoint: .bottom, endPoint: .top))
                .onAppear(){
                    movieFunction.totalGenre()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("My Netflix")
                            .font(.title)
                            .bold()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack{
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
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
