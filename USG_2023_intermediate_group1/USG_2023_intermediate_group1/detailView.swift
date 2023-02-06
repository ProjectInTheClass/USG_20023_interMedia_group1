//
//  detailView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/07.
//

import SwiftUI

struct detailView: View {
    var MId = ""
    @State var actors = [Actors]()
    @State var comments = [Comment]()
    @State var MovieDetail : RespoMovie?
    
    @State var progress: Bool = true
    
    init(_id: String = "631f9079842a834b759419d9"){
        self.MId = _id
    }
    
    func getDetails(){
        let urlStr = "http://mynf.codershigh.com:8080/api/movies/\(MId)"
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                print("1")
                let response = try decoder.decode(RespoMovie.self, from: data!)
                print("2")
                DispatchQueue.main.async {
                    self.actors = response.actors
                    self.comments = response.comments
                    self.MovieDetail = response
                    print(comments.count)
                    progress = false
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
    var body: some View {
        if progress {
            ProgressView()
                .onAppear(){
                    getDetails()
                }
        } else {
            GeometryReader { geometry in
                ScrollView(){
                    VStack{
                        
                            AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080"+MovieDetail!.image)) {img in
                                ZStack{
                                
                                img.image?.resizable()
                                    .frame(width:geometry.size.width)
                                    .opacity(0.3)
                                img.image
                                
                            }
                        }
                        Text("영화 정보")
                        
                        Text(MovieDetail!.title)
                        Text("개봉 연도 \(MovieDetail!.year)년")
                        HStack{
                            Text("장르:")
                            ForEach(MovieDetail!.genre, id: \.self){ genre in
                                Text(genre+",")
                            }
                        }
                        ScrollView{
                            HStack{
                                ForEach(actors, id: \._id) { actor in
                                    VStack{
                                        AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080"+actor.image)) { image in
                                            image.image?
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        }
                                        Text(actor.name)
                                    }
                                }
                            }
                        }
                        ForEach(comments, id: \._id) { comment in
                            VStack{
                                HStack{
                                    Text(comment.name)
                                    Text(comment.userId)
                                    Text(String(comment.rating))
                                }
                                Text(comment.text)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RespoMovie: Decodable {
    let _id: String
    let title: String
    let year: Int
    let image: String
    let genre: [String]
    let actors: [Actors]
    let comments: [Comment]
    
    enum CodingKeys :String, CodingKey {
        case _id
        case title
        case year
        case image
        case genre
        case actors
        case comments
        
        case data
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self._id = try dataContainer.decode(String.self, forKey: ._id)
        self.title = try dataContainer.decode(String.self, forKey: .title)
        self.year = try dataContainer.decode(Int.self, forKey: .year)
        self.image = try dataContainer.decode(String.self, forKey: .image)
        self.genre = try dataContainer.decode([String].self, forKey: .genre)
        self.actors = try dataContainer.decode([Actors].self, forKey: .actors)
        self.comments = try dataContainer.decode([Comment].self, forKey: .comments)
    }
}

struct Actors: Codable {
    let _id: String
    let name: String
    let image: String
}

struct Comment: Codable {
    let _id: String
    let userId: String
    let name: String
    let text: String
    let rating: Float
}

struct detailView_Previews: PreviewProvider {
    static var previews: some View {
        detailView()
    }
}
