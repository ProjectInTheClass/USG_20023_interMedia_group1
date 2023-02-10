//
//  GenreStack.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/10.
//

import SwiftUI

struct GenreStack: View {
    @StateObject var movieFunction = MovieFunction()
    
    @State var movieArray = [Movie]()
    public var inputs: String?
    
    var body: some View {
        VStack(alignment: .leading){
            Text(inputs ?? "")
                .font(.title3)
                .onAppear(){
                    movieFunction.GetResponse(inputs: self.inputs ?? "", skip: 0)
                }
            ScrollView(.horizontal){
                HStack{
                    if movieFunction.searchSuccess {
                        VStack{}.onAppear(){
                            let response =  movieFunction.searchResponse!
                            self.movieArray = response.data
                        }
                    } else {
                        ProgressView()
                    }
                    ForEach(movieArray, id: \._id) { movie in
                        AsyncImage(url: URL(string: "http://mynf.codershigh.com:8080\(movie.image ?? "")")){ img in
                            img
                                .resizable()
                                .scaledToFill()
                            //.aspectRatio(contentMode: .fill)
                                .frame(width: 200/1.47,height: 200)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .cornerRadius(10)
                                .foregroundColor(.secondary)
                                .frame(width: 100/sqrt(2),height: 100)
                        }
                    }
                }
            }
        }
    }
}

struct GenreStack_Previews: PreviewProvider {
    static var previews: some View {
        GenreStack()
    }
}
