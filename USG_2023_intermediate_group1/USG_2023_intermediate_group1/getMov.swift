//
//  getMov.swift
//
//  Created by 안병욱 on 2023/01/30.
//

import SwiftUI

struct getMov: View {
    
    @State var respo = [Movie]() // 무비 데이터
    @State var inputVal = "" // 검색어
    @State var isresultsEmpty = false // 검색 결과
    @Environment(\.dismiss) private var dismiss // 커스텀 Back 버튼 Back 변수
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView{  
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
                // 검색 결과 있으면 리스트 그림.
                    if !isresultsEmpty {
                        //MARK: 리스트
                        List(respo, id: \._id) { Rdata in
                            NavigationLink(destination: detailView(_id: Rdata._id)){
                                HStack{
                                    AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(Rdata.image)")){ img in
                                        img.image?
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 100)
                                    }
                                    VStack(alignment: .leading){
                                        Text(Rdata.title)
                                            .font(.title2)
                                            .bold()
                                            .padding(.bottom, 5)
                                        HStack{
                                            //Text("장르: ")
                                            ForEach(Rdata.genre, id: \.self){ genre in
                                                Text(genre+".")
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
                // 검색 결과 검색 결과 없음 전시
                    } else {
                        Text("\n검색 결과 없음.")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .background(.black)
                
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    //MARK: 영화 장르 검색 데이터 가져오기
    func GetResponse(inputs: String) {
        let urlStr = "http://mynf.codershigh.com:8080/api/movies?genre=\(inputVal)"
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
                    //return
                } else {
                    self.isresultsEmpty = false
                }
                DispatchQueue.main.async {
                    self.respo = response.data
                    
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
    
    func border( _ geometry: GeometryProxy) -> some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                //.padding(.trailing,-5)
                .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
            /*RoundedRectangle(cornerRadius: 10)
                .strokeBorder(LinearGradient(gradient: .init(
                    colors: [
                        Color(red: 1, green: 112 / 255.0, blue: 0),
                        Color(red: 226 / 255.0, green: 247 / 255.0, blue: 5 / 255.0)
                    ]),startPoint: .topLeading,endPoint: .bottomTrailing),lineWidth: 2)
                .frame(height: 40)
                //.padding(.trailing,-5)
                //.padding(.leading, -20)
             */
            HStack{
                Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 20, height: 20)
                TextField( "검색", text: $inputVal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.white)
                    .modifier(PlaceholderStyle(showPlaceHolder: inputVal.isEmpty, placeholder: "검색"))
                    //.background(.red)
                    .onSubmit {
                        GetResponse(inputs: inputVal)
                    }
                if !inputVal.isEmpty {
                    Button {
                        inputVal = ""
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
}

//MARK: Response 디코드
struct Response: Decodable {
    let message: String
    let data: [Movie]
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
        case total
        
        case paging
    }
    
    init(from decoder: Decoder) throws {
        let Contaniner = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try Contaniner.decode([Movie].self, forKey: .data)
        self.message = try Contaniner.decode(String.self, forKey: .message)
        
        let pagingContainer = try Contaniner.nestedContainer(keyedBy: CodingKeys.self, forKey: .paging)
        self.total = try pagingContainer.decode(Int.self, forKey: .total)
    }
    
}

struct Movie: Codable {
    let title: String
    let _id: String
    let image: String
    let genre: [String]
}


struct getMov_Previews: PreviewProvider {
    static var previews: some View {
        getMov()
    }
}
