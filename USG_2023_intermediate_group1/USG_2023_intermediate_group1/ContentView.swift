//
//  ContentView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/06.
// 홈

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
                    if movieFunction.allGenreSuccess && GenreRArray.isEmpty {
                        VStack{}.onAppear(){
                            let response = movieFunction.genreResponse!
                            //MARK: - 전체 장르 중에서 6만 중복 없이 선택
                            while RandomGenre.count != 6 {
                                
                                // 장르가 서버에서 데이터를 가져오면 \n이 들어있어 뷰가 이상하게 그려지고 동일항 장르 전시 됨.
                                // trimingCharacters 로 \n을 제거.
                                let str = response.data.randomElement()!.trimmingCharacters(in: ["\n"])
                                RandomGenre.insert(str) // Set은 원소 겹치지 않음.
                            }
                            // 원소의 순서 필요 -> 배열에 대입
                            GenreRArray.append(contentsOf: Array(RandomGenre))
                            movieFunction.allGenreSuccess = false
                        }
                    }
                    if !GenreRArray.isEmpty {
                        //MARK: 대표 영화 추천
                        NavigationLink {
                            detailView(_id: movieMain._id)
                        } label: {
                            ZStack(alignment: .bottom){
                                // SF 장르 .first 영화가 아바타라서 아바타 제외하기 위해
                                // 아바타는 포스터가 가로 부분에 흰 줄 있는데 클립 후 활용하고 정형화 하기에는 무리가 있어 제외함.
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
                        }
                        //MARK: 추천 장르별 영화 뷰
                        ForEach(GenreRArray, id: \.self){ genre in
                            GenreStack(inputs: genre)
                        }
                    }
                }
                .background(.linearGradient(colors: [.black, .indigo.opacity(0.5)], startPoint: .bottom, endPoint: .top))
                .onAppear(){
                    // 뷰가 생기자 마자 추천 장르 데이터 가져옴.
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
