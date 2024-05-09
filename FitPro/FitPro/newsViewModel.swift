//
//  newsViewModel.swift
//  FitPro
//
//  Created by Sarthak Aggarwal on 4/16/24.
//

import Foundation

class newsViewModel : ObservableObject
{
    // data structure that store news objects from google news
    @Published var newsData:[Article] = []
    
    //data structure that store NewsArticle objects for the list view
    @Published var newsListData:[NewsArticle] = []
    
    init() { }
    
    /* call https://gnews.io/api/v4/search?... API to get news artciles
       you can read more about the API @ https://gnews.io/docs/v4#search-endpoint
       First you need to register in the website and get the API Key (free version)
     */
    func getNewsItems()
    {
        let urlAsString = "https://gnews.io/api/v4/search?q=example&lang=en&country=us&max=10&apikey=0d839f7b6bee79c07c3fa9a738da3c77"
        
        let url = URL(string: urlAsString)!
        
        let urlSession = URLSession.shared
        
        // call the API, data will contain the JSON results
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            /* use JSON decoder to decode news items from data to the news structure defined
               in the data model
             */
            let decoder = JSONDecoder()
            let jsonResult = try! decoder.decode(news.self, from: data!)
        
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            //print(jsonResult)
            
            // get news items to newsItems varibale from the decoded jsonResult
            let newsItems = jsonResult.articles
            print(newsItems.count);
            
            /* this code is sent to the main queue to process asynchronosly
             to get each news items and add to the newsData array */
            
            DispatchQueue.main.async(execute: {
                for i in 0...(newsItems.count)-1
                {
                    // y is each news item
                    let y = newsItems[i]
                    //print(y.description!)
                    
                    /*get only the title, urlm and description from the JSON results
                     newsData array is not used any other computation in this application */
                     
                    
                    let a = Article(content:"", description: y.description!,publishedAt: "",title: y.title!, url: y.url, image:URL(string: "http://www.google.com"), source: Source(name: "", url: URL(string:"http://www.google.com")))
                    
                    self.newsData.append(a)
                    //print(self.newsData.count)
                    
                    // This is used to build the List
                    self.newsListData.append(NewsArticle( title: y.title!, url: y.url!))
                }
            })
        })
        
        jsonQuery.resume()
        
    }
    
}
