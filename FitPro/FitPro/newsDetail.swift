//
//  newsDetail.swift
//  FitPro
//
//  Created by Sarthak Aggarwal on 4/16/24.
//


import SwiftUI

struct newsDetails: View {
    // news item URL
    var newsURL:URL?
    /* Read the openURL environment value to get an instance of this structure for a given Environment. Call the instance to open a URL. */
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack{
            Text("Welcome to the news page")
        }.onAppear(perform: {
            openURL(newsURL!)
        })

    }
}

struct newsDetails_Previews: PreviewProvider {
    static var previews: some View {
        newsDetails(newsURL: URL(string: ""))
    }
}
