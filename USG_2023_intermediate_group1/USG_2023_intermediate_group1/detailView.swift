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
    @State var myMovies = [Movie]()
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
    @State var remove = false
    @State var like = false
    
    //MARK: 함수들
    
    init(_id: String = "631f93832d06ff4e337e64b9"){
        self.MId = _id
    }
    
    func isLikeAdded() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("MyMovieData", conformingTo: .json)
        print(fileurl)
        if FileManager.default.fileExists(atPath: fileurl.path()) {
            guard let js = NSData(contentsOf: fileurl) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let myData = try? decoder.decode(savingMovie.self, from: js as Data)
            self.myMovies = myData?.data ?? []
        }
        let Movie = Movie(title: MovieDetail?.title ?? "영화 제목", _id: MId, image: MovieDetail?.image, genre: MovieDetail?.genre ?? ["장르"])
        for mov in myMovies {
            if mov == Movie {
                print(Movie)
                like = true
                break
            }
        }
    }
    
    func MyMovies() {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("MyMovieData", conformingTo: .json)
        let Movie = Movie(title: MovieDetail?.title ?? "영화 제목", _id: MId, image: MovieDetail?.image, genre: MovieDetail?.genre ?? ["장르"])
        self.myMovies.append(Movie)
        let finalData = savingMovie(message: String(describing: MovieDetail!.title), data: myMovies)
        let data = try! JSONEncoder().encode(finalData)
        
        do {
            if FileManager.default.fileExists(atPath: fileurl.path()) {
                try FileManager.default.removeItem(at: fileurl)
            }
            FileManager.default.createFile(atPath: fileurl.path(), contents: data)
        } catch {
            print("mymovie encode-", error)
        }
        self.like = true
    }
    
    //MARK: 영화 세부 데이터 가져옴.
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
                    //print(comments.count)
                    progress = false
                    user.detailViewProgress = false
                }
            }
            catch {
                
            }
        }
        task.resume()    }
    
    func dislikeMovie() {
        for i in 0..<myMovies.count {
            if myMovies[i]._id == MId {
                myMovies.remove(at: i)
                break
            }
        }
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileurl = doc.appendingPathComponent("MyMovieData", conformingTo: .json)
        let finalData = savingMovie(message: String(describing: MovieDetail!.title), data: myMovies)
        let data = try! JSONEncoder().encode(finalData)
        do {
            if FileManager.default.fileExists(atPath: fileurl.path()) {
                try FileManager.default.removeItem(at: fileurl)
            }
            FileManager.default.createFile(atPath: fileurl.path(), contents: data)
        } catch {
            print("mymovie encode-", error)
        }
        self.like = false
    }
   
    
    //MARK: 뷰
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(){
                if progress || user.detailViewProgress {
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
                                    if MovieDetail!.title == "아바타"{ // 아바타는 죄가 많다.
                                        img
                                            .resizable()
                                            .frame(width:geometry.size.width + 190, height: 300)
                                            .frame(width:geometry.size.width, height: 300)
                                            .clipped()
                                            .opacity(0.3)
                                        
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300/1.49,height: 300)
                                            .clipped()
                                    }
                                    else {
                                        // 포스터 투명도 준다음 화면 크기에 맞게 가로로 늘림.
                                        img
                                            .resizable()
                                            .frame(width:geometry.size.width, height: 300)
                                            .opacity(0.3)
                                        // 원본 포스터 가져옴
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300/1.47,height: 300)
                                            .clipped()
                                            .frame(height: 300)
                                    }
                                }
                            } placeholder: {
                                Rectangle()
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
                                        // 장르가 서버에서 데이터를 가져오면 \n이 들어있어 뷰가 이상하게 그려지고 동일항 장르 전시 됨.
                                        // trimmingCharacters 로 \n을 제거하고 마지막 장르 전시 후 ',' 제거
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
                                        NavigationLink {
                                            ActorView(actorId: actor._id)
                                        } label: {
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
                                    .foregroundColor(userName == comment.name ? .black : .white)
                                    .frame(height: 40)
                                    .background(
                                        Rectangle()
                                            .cornerRadius(10)
                                            .foregroundColor(userName == comment.name ? .white.opacity(0.6) : .gray.opacity(0.5))
                                            .padding(.horizontal,-16)
                                            .padding(.top,-1)
                                    )
                                    
                                    Text(comment.text)
                                        .padding(.top, 10)
                                }
                                .frame(width: geometry.size.width - 65)
                                .padding()
                                .padding(.top, -15)
                                .background(Rectangle().cornerRadius(10).foregroundColor(userName == comment.name ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.25, green: 0.25, blue: 0.25)))
                                .padding(5)
                                .Swipes(geometry: geometry,progress: $progress, itsMe: userName == comment.name ? true : false, movieId: MId, commentId: comment._id)
                            }
                            HStack{}.frame(height: 50)
                        }
                        //.background(.black)
                        .foregroundColor(.white)
                        .preferredColorScheme(.dark)
                    }
                    //MARK: 네비게이션 뷰 커스텀 Back 버튼
                    VStack{
                        HStack{
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
                                    }
                                    //.frame(width: geometry.size.width)
                                    .bold()
                                }
                            }
                            Spacer()
                            Button {
                                if !like {
                                    MyMovies()
                                } else {
                                   dislikeMovie()
                                }
                            } label: {
                                Image(systemName: like ? "heart.circle" : "plus")
                                    .padding(10).tint(.white)
                            }.onAppear(){
                                isLikeAdded()
                            }
                        }
                        .background(.regularMaterial)
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
                            // 로그인 안된 경우에 댓글 작성하려할 경우 대응 메세지
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
                    // MARK: 별점 설정 뷰
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
                                    .clipShape(Rectangle().size(width: 110,height: 100 - ratingVal * 20)) // 클립 원점이 상단이라 반대로 설정.
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

struct detailView_Previews: PreviewProvider {
    static var previews: some View {
        detailView()
    }
}
