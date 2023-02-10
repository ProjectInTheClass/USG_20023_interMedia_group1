//
//  HomeRecommandMovie.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/10.
//

import SwiftUI

struct HomeRecommandMovie: View {
    
    @StateObject var movieFuntion = MovieFunction()
    public var genre: String?
    
    @Binding var movie: Movie
    var geometry: GeometryProxy
    
    
    var body: some View {
        ZStack{
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
