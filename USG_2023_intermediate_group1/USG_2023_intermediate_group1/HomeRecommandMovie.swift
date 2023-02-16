//
//  HomeRecommandMovie.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/10.
//  넷플릭스가 해방 뷰를 포스터 보다 작게 그려서 따라하기 위해 따로 구성한 뷰

import SwiftUI

struct HomeRecommandMovie: View {
    
    @StateObject var movieFuntion = MovieFunction()
    public var genre: String?
    
    @Binding var movie: Movie
    var geometry: GeometryProxy
    
    
    var body: some View {
        ZStack{
            // 받아온 포스터 이미지 전시
            if !(movie.title.isEmpty) {
                    AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(movie.image ?? "")")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 20)
                            .cornerRadius(20)
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    }
                // 이미지 크기가 동일하지 않으면 원하는 뷰가 그려지지 않아 비효율적이지만 같은 이미지를 같이 받아온 다음 투명도를 주고 그레데이션 그림.
                VStack{
                    AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(movie.image ?? "")")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .opacity(0)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 20)
                            .cornerRadius(20)
                            .scaledToFit()
                            .foregroundColor(.secondary)
                    }.background(LinearGradient(colors: [.black, .black.opacity(0.8), .clear, .clear], startPoint: .bottom, endPoint: .top))
                }
            }
        }.onAppear(){
            RecommandedMovie(genre: self.genre ?? "")
        }
    }
    
    //MARK: 영화 하나만 가져옴
    // 추천화면에서 추천 영화의 경우 많은 데이터를 가져오는 것은 비효율 적이라 생각하여 하나만 가져옴.
    func RecommandedMovie(genre: String) {
            let urlStr = "http://mynf.codershigh.com:8080/api/movies?genre=\(genre)&limit = 1"
            print(urlStr)
            let UrlEncode = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let url = URL(string: UrlEncode)!
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
                if error != nil || data == nil {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Response.self, from: data!)
                    DispatchQueue.main.async {
                        self.movie = response.data.first!
                    }
                }
                catch {
                    print("캐치")
                }
            }
            task.resume()
    }
}
