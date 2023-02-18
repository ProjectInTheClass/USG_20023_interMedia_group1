//
//  MyMovie.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/18.
//

import SwiftUI

struct MyMovie: View {
    
    @State var myMovies = [Movie]()
    //@State var myMoviesSet = Set<Movie>()
    
    func MyMovies() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("MyMovieData", conformingTo: .json)
        print(fileurl)
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            guard let js = NSData(contentsOf: fileurl) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let myData = try? decoder.decode(savingMovie.self, from: js as Data)
            self.myMovies = myData?.data ?? []
            var myMoviesSet = Set<Movie>()
            for movie in myMovies {
                myMoviesSet.insert(movie)
            }
            self.myMovies = Array(myMoviesSet)
            let finalData = savingMovie(message: "중복 영화 제거", data: myMovies)
            let data = try! JSONEncoder().encode(finalData)
            
            do {
                if FileManager.default.fileExists(atPath: fileurl.path()) {
                    try FileManager.default.removeItem(at: fileurl)
                }
                FileManager.default.createFile(atPath: fileurl.path(), contents: data)
            } catch {
                print("mymovie encode-", error)
            }
        }
    }
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView{
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20){
                    ForEach(myMovies, id: \._id) { movie in
                        VStack{
                            AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080" + (movie.image?.trimmingCharacters(in: ["\""]) ?? "nil"))) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                //.aspectRatio(contentMode: .fill)
                                    .frame(width: 150/1.47,height: 150)
                                    .clipped()
                                //.shadow(color: Color.secondary ,radius: 12)
                            } placeholder: {
                                Rectangle().foregroundColor(.green)
                            }
                            Text(movie.title)
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .bold()
                            Spacer()
                        }
                        //Text("영화")
                    }
                }
                .onAppear(){
                    MyMovies()
                }
            }
        }
    }
}

struct MyMovie_Previews: PreviewProvider {
    static var previews: some View {
        MyMovie()
    }
}
