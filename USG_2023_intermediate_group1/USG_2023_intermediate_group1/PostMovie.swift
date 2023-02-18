//
//  PostMovie.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/16.
//

import SwiftUI

struct PostMovie: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var user = User()
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    @State var alertOn = false
    
    @State var title = ""
    @State var genre = ""
    @State var genreArray = [String]()
    @State var genreSet = Set<String>()
    
    @State var actors = ""
    @State var actorsArray = [String]()
    @State var actorsSet = Set<String>()
    
    var noweDates: Int {
        get {
            let nowDate = Date.now
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let strDate = formatter.string(from: nowDate)
            return Int(strDate)!
        }
    }
    @State var releaseDate: Int = 1999
    @State var yearSelected = false
    
    @State var moviePoster: UIImage?
    @State var imagePickerSel = false
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                ScrollView{
                    Spacer().frame(height: 50)
                    VStack(alignment: .center){
                        ZStack{
                            Rectangle()
                                .cornerRadius(20)
                                .foregroundColor(.secondary)
                                .frame(width: 300, height: 300*sqrt(2))
                                .sheet(isPresented: $imagePickerSel) {
                                    ImagePicker(image: $moviePoster)
                                }
                            if moviePoster != nil {
                                Image(uiImage: moviePoster!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300*sqrt(2))
                                    .clipped()
                                    .onTapGesture {
                                        self.imagePickerSel = true
                                    }
                                
                            } else {
                                Button {
                                    self.imagePickerSel = true
                                } label: {
                                    Image(systemName: "plus.square.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                        .shadow(radius: 20)
                                }
                            }
                        }
                        TextField("", text: $title)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .modifier(PlaceholderStyle(showPlaceHolder: title.isEmpty, placeholder: "영화 제목", color: Color.gray))
                            .font(.title)
                            .bold()
                            .padding(.horizontal)
                        Button {
                            self.yearSelected = true
                        } label: {
                            HStack{
                                Text("개봉 연도: ")
                                Spacer()
                                Text(String(releaseDate))
                                    .onAppear(){
                                        self.releaseDate = noweDates
                                    }
                            }
                        }
                        .padding(.horizontal)
                        if yearSelected{
                            Picker(selection: $releaseDate) {
                                ForEach(1895..<noweDates+20, id: \.self) { index in
                                    Text(String(index))
                                }
                            } label: {}
                                .pickerStyle(.wheel)
                                .padding(.horizontal, 50)
                            /*
                             DatePicker("개봉 연도", selection: $releaseDate, displayedComponents: [.date])
                             .datePickerStyle(.wheel)
                             */
                            Button("확인"){
                                yearSelected = false
                            }
                        }
                        HStack{
                            Text("장르: ")
                            TextField("", text: $genre)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .modifier(PlaceholderStyle(showPlaceHolder: genre.isEmpty, placeholder: "입력"))
                                .onSubmit {
                                    let genreStr = self.genre
                                    var genreWord = ""
                                    for cha in genreStr {
                                        if cha == Character(" ") || cha == Character(",") {
                                            guard !genreWord.isEmpty else {continue}
                                            genreSet.insert(genreWord)
                                            genreWord = ""
                                            continue
                                        }
                                        genreWord += String(cha)
                                    }
                                    genreSet.insert(genreWord)
                                    genreArray.append(contentsOf: Array(genreSet))
                                }
                            
                        }
                        .padding(.horizontal)
                        HStack{
                            Text("배우: ")
                            TextField("", text: $actors)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .foregroundColor(.white)
                                .modifier(PlaceholderStyle(showPlaceHolder: actors.isEmpty, placeholder: "입력"))
                                .onSubmit {
                                    let actorsStr = self.actors
                                    var actorsWord = ""
                                    for cha in actorsStr {
                                        if cha == Character(" ") || cha == Character(",") {
                                            guard !actorsWord.isEmpty else {continue}
                                            actorsSet.insert(actorsWord)
                                            actorsWord = ""
                                            continue
                                        }
                                        actorsWord += String(cha)
                                    }
                                    actorsSet.insert(actorsWord)
                                    actorsArray.append(contentsOf: Array(actorsSet))
                                }
                        }
                        .padding(.horizontal)
                        Button{
                            if self.UserId.isEmpty {
                                self.alertOn = true
                            } else {
                                guard let img = moviePoster else {return}
                                let imgData = img.jpegData(compressionQuality: 0.5)
                                user.moviePost(image: imgData!, title: self.title, year: self.releaseDate, genre: self.genreArray, actors: self.actorsArray)
                            }
                        } label: {
                            ZStack{
                                Rectangle()
                                    .cornerRadius(8)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal)
                                    .frame(width: geometry.size.width, height: 40)
                                
                                Text("전송")
                                    .padding(10)
                            }
                        }
                        .foregroundColor(.black)
                        .alert("로그인이 필요한 서비스 입니다.", isPresented: $alertOn) {
                            NavigationLink(destination: logins()) {
                                Text("로그인")
                                    .tint(.red)
                            }
                            Button("취소"){}
                        }
                        
                        Spacer()
                    }
                    .preferredColorScheme(.dark)
                    .tint(.white)
                }
                .background {
                    Color.indigo.opacity(0.2)
                        .ignoresSafeArea()
                }
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
struct PostMovie_Previews: PreviewProvider {
    static var previews: some View {
        PostMovie()
    }
}
