//
//  ActorView.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/17.
//

import SwiftUI

struct ActorView: View {
    
    @State var progress = true
    @State var response: AcotorResponse!
    
    @Environment(\.dismiss) private var dismiss
    
    var actorId: String
    init(actorId: String = "631f9154842a834b759419db"){
        self.actorId = actorId
    }
    var body: some View {
        GeometryReader{ geometry in
            if progress {
                ProgressView() // 로딩
                    .onAppear(){
                        getActorInfo(actorId: actorId)
                    }
            } else {
                ZStack{
                    ScrollView{
                        VStack{
                            VStack{}.frame(height: 50)
                            AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080" + (response.actor?.image ?? ""))) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .secondary ,radius: 20)
                            } placeholder: {
                                Rectangle()
                            }
                            .frame(width: geometry.size.width)
                            Text(response.actor!.name)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            HStack{
                                Text("Filmography")
                                    .font(.title2)
                                    .italic()
                                    .bold()
                                    .padding(10)
                                    .padding(.vertical, 20)
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width)
                            .background(borderGradient)
                            ScrollView(.horizontal) {
                                HStack{
                                    ForEach(response.filmography ?? [Filmography(_id: "123456789", title: "영화 제목", year: 1999, image: "/poster/1667381166275.jpg")], id: \._id) { filmography in
                                        
                                        VStack{
                                            NavigationLink {
                                                detailView(_id: filmography._id)
                                            } label: {
                                                AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080" + (filmography.image))) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                    //.aspectRatio(contentMode: .fill)
                                                        .frame(width: 150/1.47,height: 150)
                                                        .clipped()
                                                        //.shadow(color: Color.secondary ,radius: 12)
                                                } placeholder: {
                                                    Rectangle()
                                                }
                                            }
                                            Text(filmography.title)
                                                .foregroundColor(.white)
                                                .bold()
                                            Text(String(filmography.year))
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                }
                                
                            }
                        }
                    }.preferredColorScheme(.dark)
                        .background {
                            LinearGradient(colors: [Color.cyan.opacity(0.3), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                    }
                    .toolbar(.hidden)
                }
            }
        }
    }
    
    func getActorInfo(actorId: String) {
        let urlStr = "http://mynf.codershigh.com:8080/api/actors/\(actorId)"
        let url = URL(string: urlStr)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(AcotorResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.progress = false
                    self.response = response
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
    
    var borderGradient: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(LinearGradient(gradient: .init(
                colors: [
                    Color.white,
                    Color.secondary
                ]),startPoint: .topLeading,endPoint: .bottomTrailing),lineWidth: 2)
            .frame(height: 50)
            .padding(0)
        
        
    }
}


struct ActorView_Previews: PreviewProvider {
    static var previews: some View {
        ActorView()
    }
}
