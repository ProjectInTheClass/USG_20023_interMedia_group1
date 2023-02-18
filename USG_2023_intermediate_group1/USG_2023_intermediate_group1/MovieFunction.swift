//
//  MovieFunction.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/10.
//

import Foundation
class MovieFunction: ObservableObject {
    
    @Published var searchResponse: Response?
    @Published var genreResponse: genreRespo?
    @Published var searchSuccess = false
    @Published var allGenreSuccess = false
    
    //MARK: 영화 장르 검색 데이터 가져오기
    func GetResponse(inputs: String, skip: Int) {
        let urlStr = "http://mynf.codershigh.com:8080/api/movies?genre=\(inputs)&skip=\(skip)" //skip에 따라 데이터 건너띄고 가져옴.
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
                DispatchQueue.main.async {
                    self.searchResponse = response
                    self.searchSuccess = true
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
        let url = "http://mynf.codershigh.com:8080/api/genres"
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(genreRespo.self, from: data!)
                print(response.message)
                DispatchQueue.main.async {
                    self.genreResponse = response
                    self.allGenreSuccess = true
                }
            }
            catch {
                
            }
        }
        task.resume()
    }
}
