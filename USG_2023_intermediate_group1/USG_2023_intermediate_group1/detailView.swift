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
    
    init(_id: String = "631f93832d06ff4e337e64b9"){
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
                    //print((response.year))
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
    var body: some View {
        if progress {
            ProgressView() // 로딩
                .onAppear(){
                    getDetails()
                }
        } else {
            GeometryReader { geometry in
                ScrollView(){
                    // 영화 포스터
                    VStack(){
                        AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080"+MovieDetail!.image)) {img in
                            //let Images = img.image
                            ZStack{
                                img.image?
                                    .resizable()
                                    .frame(width:geometry.size.width, height: 300)
                                    .opacity(0.3)
                                img.image?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                                
                            }
                        }
                        // 영화 정보
                        HStack{
                            VStack(alignment: .leading){
                                Text(MovieDetail!.title)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(.bottom,10)
                                Text("개봉: " + String(MovieDetail!.year) + " 년")
                                HStack{
                                    Text("장르: ")
                                    ForEach(MovieDetail!.genre, id: \.self){ genre in
                                        Text(genre+",")
                                    }
                                }
                            }
                            .padding(.leading, 10)
                            Spacer()
                        }
                        //MARK: 배우 뷰
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(actors, id: \._id) { actor in
                                    VStack{
                                        AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080"+actor.image)) { image in
                                            image.image?
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 100)
                                                .clipShape(Circle())
                                        }
                                        Text(actor.name)
                                            .lineLimit(2)
                                            .onAppear(){
                                                print(actor.name)
                                            }
                                    }
                                    .frame(width: 100,height: 160)
                                    .padding()
                                    .background(Rectangle().cornerRadius(15).foregroundColor(.secondary).opacity(0.5))
                                    .padding(5)
                                }
                            }
                        }
                        // MARK: 뎃글 뷰
                        Text("\n댓글")
                            .font(.title)
                        ForEach(comments, id: \._id) { comment in
                            VStack(alignment: .leading){
                                HStack(){
                                    Text(comment.name)
                                        .bold()
                                        .font(.headline)
                                    Text(comment.userId)
                                    Spacer()
                                    Image(systemName: "star")
                                    Text(String(comment.rating))
                                }
                                .frame(height: 40)
                                .background(
                                    Rectangle()
                                        .cornerRadius(10)
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                        .padding(.horizontal,-15)
                                )
                                
                                Text(comment.text)
                                    .padding(.top, 10)
                            }
                            .frame(width: geometry.size.width - 65)
                            .padding()
                            .padding(.top, -15)
                            .background(Rectangle().cornerRadius(10).foregroundColor(.secondary).opacity(0.5))
                            .padding(5)
                            
                        }
                    }
                    //.background(.black)
                    .foregroundColor(.white)
                    .preferredColorScheme(.dark)
                }
            }
        }
    }
}
//MARK: 영화 아이디로 받아온 데이터 디코딩
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
