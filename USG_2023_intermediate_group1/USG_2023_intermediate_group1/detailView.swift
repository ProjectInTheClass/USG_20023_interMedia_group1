//
//  detailView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/07.
//

import SwiftUI

struct detailView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    @AppStorage("userName") var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    
    var MId = ""
    @State var actors = [Actors]()
    @State var comments = [Comment]()
    @State var MovieDetail : RespoMovie?
    @State var islogin: Bool = false
    @State var commentsisEmpty = false
    
    @State var progress: Bool = true
    @State var commentInput = ""
    
    @State var SetStar: Bool = false
    @State var ratingVal: Double = 5.0
    
    @StateObject var user = User()
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
                let response = try decoder.decode(RespoMovie.self, from: data!)
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
        GeometryReader { geometry in
            ZStack(){
                if progress {
                    ProgressView() // 로딩
                        .onAppear(){
                            getDetails()
                        }
                } else {
                    ScrollView(){
                        // 영화 포스터
                        VStack(){
                            HStack{}.frame(height: 30)
                            AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(MovieDetail!.image ?? "")"))  {img in
                                //let Images = img.image
                                ZStack{
                                    if MovieDetail!.title == "아바타"{
                                        img.image?
                                            .resizable()
                                            .frame(width:geometry.size.width + 190, height: 300)
                                            .frame(width:geometry.size.width, height: 300)
                                            .clipped()
                                            .opacity(0.3)
                                        img.image?
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300/1.49,height: 300)
                                            .clipped()
                                    }
                                    else {
                                        img.image?
                                            .resizable()
                                            .frame(width:geometry.size.width, height: 300)
                                            .opacity(0.3)
                                        img.image?
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300/1.47,height: 300)
                                            .clipped()
                                            .frame(height: 300)
                                    }
                                }
                            }
                            // 영화 정보
                            HStack{
                                VStack(alignment: .leading){
                                    Text(MovieDetail!.title)
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(.bottom,10)
                                    Text("개봉: " + String(MovieDetail!.year ?? 9999) + " 년")
                                    HStack{
                                        Text("장르: ")
                                        ForEach(MovieDetail!.genre, id: \.self){ genre in
                                            if MovieDetail?.genre.last == genre {
                                                Text(genre.trimmingCharacters(in: ["\n"]))
                                            } else {
                                                Text(genre.trimmingCharacters(in: ["\n"])+",")
                                            }
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
                                                    .padding(.bottom, 8)
                                            }
                                            Text(actor.name+"\n")
                                                .lineLimit(2)
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
                            HStack{}.frame(height: 50)
                        }
                        //.background(.black)
                        .foregroundColor(.white)
                        .preferredColorScheme(.dark)
                    }
                    //MARK: 네비게이션 뷰 커스텀 Back 버튼
                    VStack{
                        Button {
                            dismiss()
                        } label: {
                            Button {
                                dismiss()
                            } label: {
                                HStack(spacing: 0){
                                    Image(systemName: "chevron.backward")
                                        .foregroundColor(.white)
                                        .padding(10)
                                    Text("Back")
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .frame(width: geometry.size.width)
                                .bold()
                            }
                        }
                        .background(.thickMaterial)
                        Spacer()
                        //MARK: 댓글 작성
                        HStack{
                            TextField("댓글을 입력하세요", text: $commentInput)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Button {
                                self.SetStar = true
                            } label: {
                                HStack{
                                    Image(systemName: "star")
                                    Text("\(ratingVal, specifier: "%.1f")")
                                }
                            }
                            Button {
                                if !UserId.isEmpty {
                                    if !self.commentInput.isEmpty {
                                    user.commentWrite(id: MId, rating: Float(ratingVal), text: commentInput)
                                        comments.append(Comment(_id: MId, userId: UserId, name: userName, text: commentInput, rating: Float(ratingVal)))
                                        commentInput = ""
                                    } else {
                                        self.commentsisEmpty = true
                                    }
                                } else {
                                    self.islogin = true
                                }
                            } label: {
                                Text("등록")
                                    .foregroundColor(.black)
                            }
                            .buttonStyle(.borderedProminent)
                            .alert("로그인이 필요한 서비스 입니다.", isPresented: $islogin) {
                                NavigationLink(destination: logins()) {
                                    Text("로그인")
                                        .tint(.red)
                                }
                                Button("취소"){}
                            }
                            .alert("댓글이 비어 등록할 수 없습니다.", isPresented: $commentsisEmpty) {
                                
                            }
                            
                        }
                        .tint(Color.white)
                        .padding(10)
                        .background(Color(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)))
                    }
                    if SetStar {
                        VStack{
                            Text("별점")
                            ZStack{
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .clipShape(Rectangle().size(width: 110,height: 100 - ratingVal * 20))
                                Image(systemName: "star")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                            HStack{
                                Slider(value: $ratingVal, in: 0...5, step: 0.1)
                                Text("\(ratingVal, specifier: "%.1f")")
                            }
                            .padding()
                            Button {
                                self.SetStar = false
                            } label: {
                                Text("확인")
                            }
                        }
                        .frame(width: 200, height: 260)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                        
                    }
                }
            }.toolbar(.hidden)
        }
    }
}
//MARK: 영화 아이디로 받아온 데이터 디코딩
struct RespoMovie: Decodable {
    let _id: String
    let title: String
    let year: Int?
    let image: String?
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
        print("ds")
        self._id = try dataContainer.decode(String.self, forKey: ._id)
        print("ds")
        self.title = try dataContainer.decode(String.self, forKey: .title)
        print("ds")
        self.year = try dataContainer.decode(Int.self, forKey: .year)
        print("ds")
        self.image = try? dataContainer.decode(String.self, forKey: .image)
        print("ds")
        self.genre = try dataContainer.decode([String].self, forKey: .genre)
        print("q")
        self.actors = try dataContainer.decode([Actors].self, forKey: .actors)
        print("e")
        self.comments = try dataContainer.decode([Comment].self, forKey: .comments)
        print("no")
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
