//
//  getMov.swift
//
//  Created by 안병욱 on 2023/01/30.
//

import SwiftUI

struct getMov: View {
    
    @State var respo = [Movie]() // 무비 데이터
    @State var inputValue = "" // 검색어
    @State var isresultsEmpty = false // 검색 결과
    @Environment(\.dismiss) private var dismiss // 커스텀 Back 버튼 Back 변수
    @State var genreSelected = false
    
    @State var totalGenres = [String]()
    @State var RandomGenre = Set<String>()
    @State var GenreRArray = [String]()
    @State var movieTotal: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack{  
                VStack(spacing: 0){
                    HStack{
                        //커스텀 Back 버튼
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.white)
                                .padding(10)
                        }

                        border(geometry)
                            .padding(10)
                    }
                    //MARK: 검색어 추천
                    if respo.isEmpty{
                        genreRecommand(geometry)
                            .onAppear(){
                                totalGenre()
                            }
                    }
                    /*
                    if !genreSelected && isresultsEmpty{
                        genreView(geometry: geometry, inputValue: $inputValue, genreSelected: $genreSelected)
                    } else {
                        VStack{}.onAppear(){
                            GetResponse(inputs: inputValue)
                        }
                    }*/
                // 검색 결과 있으면 리스트 그림.
                    if !isresultsEmpty {
                        //MARK: 리스트
                        List(respo, id: \._id) { Rdata in
                            NavigationLink(destination: detailView(_id: Rdata._id)){
                                HStack{
                                    AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(Rdata.image ?? "")")){ img in
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            //.aspectRatio(contentMode: .fill)
                                            .frame(width: 100/1.47,height: 100)
                                            .clipped()
                                    } placeholder: {
                                        Rectangle()
                                            .cornerRadius(10)
                                            .foregroundColor(.secondary)
                                            .frame(width: 100/sqrt(2),height: 100)
                                    }
                                    VStack(alignment: .leading){
                                        Text(Rdata.title)
                                            .font(.title2)
                                            .bold()
                                            .padding(.bottom, 5)
                                        HStack{
                                            //Text("장르: ")
                                            ForEach(Rdata.genre , id: \.self){ genre in
                                                if Rdata.genre.last == genre {
                                                    Text(genre.trimmingCharacters(in: ["\n"]))
                                                } else {
                                                    Text(genre.trimmingCharacters(in: ["\n"])+",")
                                                }
                                            }
                                        }
                                    }.padding(5)
                                }
                            }
                            .preferredColorScheme(.dark)
                            
                        }
                        .listStyle(.plain)
                        .ignoresSafeArea(.all, edges: .bottom)
                        .background(.black)
                        if self.movieTotal != respo.count{
                            Button("더보기"){
                                GetResponse(inputs: inputValue, skip: respo.count)
                                print("버튼 실행함")
                            }
                        }
                // 검색 결과 검색 결과 없음 전시
                    } else {
                        Text("\n검색 결과 없음.")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .background(.black)
                
            }
        }.preferredColorScheme(.dark)
        .toolbar(.hidden)
    }
    
    //MARK: 영화 장르 검색 데이터 가져오기
    func GetResponse(inputs: String, skip: Int) {
        let urlStr = "http://mynf.codershigh.com:8080/api/movies?genre=\(inputs)&skip=\(skip)"
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
                let resultCount = response.total
                if resultCount == 0 {
                    self.isresultsEmpty = true
                    print(resultCount)
                    
                } else {
                    self.isresultsEmpty = false
                }
                DispatchQueue.main.async {
                    
                    self.movieTotal = response.total
                    if respo.count < self.movieTotal && skip > 0 {
                        self.respo.append(contentsOf: response.data)
                    } else {
                        self.respo = response.data
                    }
                    print("\(respo.count), \(response.total)")
                    
                }
            }
            catch {
                print("캐치")
            }
        }
        task.resume()
    }
    
    //MARK: 전체 장르 종류 가져오기
    func totalGenre() {
        let urlStr = "http://mynf.codershigh.com:8080/api/genres"
        let UrlEncode = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: UrlEncode)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(genreRespo.self, from: data!)
                print(response.message)
                DispatchQueue.main.async {
                    while RandomGenre.count != 6 {
                        let str = response.data.randomElement()!.trimmingCharacters(in: ["\n"])
                        RandomGenre.insert(str)
                    }
                    GenreRArray.append(contentsOf: Array(RandomGenre))
                    self.totalGenres = response.data
                    //print(GenreRArray)
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
    
    //MARK: SearchBar
    func border( _ geometry: GeometryProxy) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                //.padding(.trailing,-5)
                .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
            HStack{
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 20, height: 20)
                TextField( "검색", text: $inputValue)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.white)
                    .modifier(PlaceholderStyle(showPlaceHolder: inputValue.isEmpty, placeholder: "검색"))
                //.background(.red)
                    .onSubmit {
                        GetResponse(inputs: inputValue, skip: 0)
                    }
                if !inputValue.isEmpty {
                    Button {
                        inputValue = ""
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }

                }
                    
            }
            .padding(.leading, 10)
            //.frame(width: geometry.size.width - 100)
        }
    }
    
    //MARK: 장르 추천 뷰
    func genreRecommand(_ geometry: GeometryProxy) -> some View {
        HStack{
            VStack{
                ForEach(0..<GenreRArray.count/2, id: \.self) { i in
                    Button {
                        inputValue = GenreRArray[i]
                        GetResponse(inputs: GenreRArray[i], skip: 0)
                    } label: {
                        Text(GenreRArray[i])
                            .font(.title3)
                            .lineLimit(1)
                            .padding(10)
                    }
                }.frame(width: geometry.size.width/2)
            }
            VStack{
                ForEach(GenreRArray.count/2..<GenreRArray.count, id: \.self) { i in
                    Button {
                        inputValue = GenreRArray[i]
                        GetResponse(inputs: GenreRArray[i], skip: 0)
                    } label: {
                        Text(GenreRArray[i])
                            .font(.title3)
                            .padding(10)
                            .lineLimit(1)
                    }
                }.frame(width: geometry.size.width/2)
            }
        }
    }
}

//MARK: Response 디코드
struct Response: Decodable {
    let message: String
    let data: [Movie]
    let total: Int
    let skip: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
        case total
        case skip
        
        case paging
    }
    
    init(from decoder: Decoder) throws {
        let Contaniner = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try Contaniner.decode([Movie].self, forKey: .data)
        self.message = try Contaniner.decode(String.self, forKey: .message)
        
        let pagingContainer = try Contaniner.nestedContainer(keyedBy: CodingKeys.self, forKey: .paging)
        self.total = try pagingContainer.decode(Int.self, forKey: .total)
        self.skip = try pagingContainer.decode(Int.self, forKey: .skip)
    }
    
}

struct Movie: Codable {
    let title: String
    let _id: String
    let image: String?
    let genre: [String]
}
struct genreRespo: Decodable {
    let message: String
    let data: [String]
}

struct getMov_Previews: PreviewProvider {
    static var previews: some View {
        getMov()
    }
}
