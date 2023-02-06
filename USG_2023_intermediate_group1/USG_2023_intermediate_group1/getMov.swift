//
//  getMov.swift
//  Usg01
//
//  Created by 안병욱 on 2023/01/30.
//

import SwiftUI

struct getMov: View {
    @State var respo = [Movie]()
    
    var body: some View {
        VStack{
            List(respo, id: \._id) { Rdata in
                HStack{
                    AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(Rdata.image)")){ img in
                        img.image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    } 
                    Text(Rdata.title)
                }
            }
            Button {
                GetResponse()
                //makeEncode()
            } label: {
                Text("Get")
                    .padding()
            }

        }
    }
    
    
    func GetResponse() {
        let urlStr = "http://mynf.codershigh.com:8080/api/movies"
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data!)
                DispatchQueue.main.async {
                    self.respo = response.data
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
}
func makeEncode() {
    let datas = Movie(title: "타이틀", _id: "아이디", image: "이미지", genre: ["스릴러"])
    let encoder = JSONEncoder()
    let dts = try! encoder.encode(datas)
    print("dts",dts)
}
struct Response: Codable {
    let message: String
    let data: [Movie]
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
