//
//  ContentView.swift
//  FitPro
//
//  Created by Sarthak Aggarwal on 4/15/24.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [meal]
    
    @ObservedObject var newsItemVM: newsViewModel
    @State var newssheet = false
    
    @State var isShowingDataEntry = false
    @State var mealName = ""
    @State var calories = ""
    @State var date = Date()
    @State var showingSaveAlert = false
    @State var showingGym = false
    
    let currentDate = Date()
    let dateFormatter = DateFormatter()

    var body: some View {
        NavigationView{
            VStack{
                Spacer()
                Spacer()
                Text("Total Calories Consumed Today: \(getTodaysCal())")
                Spacer()
                Button("Get Fitness News"){
                    newssheet.toggle()
                    newsItemVM.getNewsItems()
                }.sheet(isPresented: $newssheet){
                    List{
                        //pass the URL of the news article to the newDetails view
                        ForEach(newsItemVM.newsListData, id: \.id){ newsItem in
                            NavigationLink(destination: newsDetails(newsURL: newsItem.url)){
                                Text(newsItem.title ?? "Test")
                            }
                        }
                    }
                }
                Spacer()
                Text("Meals consumed today:")
                Spacer()
                Text("\(meals.count)").font(.system(size: 1))
                List(getList(), id: \.calories){ oneMeal in
                    HStack{
                        if(matchDates(m: oneMeal)){
                            Text("\(oneMeal.name)")
                            Text("\(oneMeal.calories)")
                            Text("\(meals.count)").font(.system(size: 1))
                        }
                    }
                }
                Spacer()
                Spacer()
                // end Vstack
            }.navigationTitle("FitPro")
                
                .navigationBarItems(leading: Button("Add") {isShowingDataEntry.toggle()}, trailing: Button("Show Gym"){showingGym.toggle()}).sheet(isPresented: $isShowingDataEntry){
                    Form{
                        Section(header: Text("Details")){
                            TextField("Name", text: $mealName)
                            TextField("Calories", text: $calories)
                            DatePicker(
                                "Transaction date",
                                selection: $date
                            )
                            .datePickerStyle(CompactDatePickerStyle())
                            .frame(maxHeight: 400)
                            Text("\(meals.count)").font(.system(size: 1))
                        }
                        Button("Save Transaction"){
                            let oneMeal = meal(name: mealName, calories: Int(calories)!, date: date)
                            modelContext.insert(oneMeal)
                            showingSaveAlert = true
                        }.alert(isPresented: $showingSaveAlert) {
                            return Alert(title: Text("Alert!"), message: Text("Meal Saved"), dismissButton: .default(Text("OK")))
                        }
                        
                    }
                }
                .sheet(isPresented: $showingGym){
                    GymMapView()
                }
        }
    }
    
    func getTodaysCal()->Int{
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        var todayscal = 0
        for i in meals{
            let dateString = dateFormatter.string(from: i.date)
            if(dateString == currentDateString){
                todayscal = todayscal + i.calories
            }
        }
        return todayscal
    }
    
    func matchDates(m: meal)-> Bool{
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: currentDate)
        let dateString = dateFormatter.string(from: m.date)
        if(dateString == currentDateString){
            return true
        }
        else{
            return false
        }
    }
    
    func getList()-> [meal]{
        let currentDateString = dateFormatter.string(from: currentDate)
        let temp = meals.filter { i in
            let dateString = dateFormatter.string(from: i.date)
            return dateString == currentDateString
        }
        return temp
    }
}

struct GymMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var initialRegion: MKCoordinateRegion?

    var body: some View {
        Map(coordinateRegion: Binding(
                get: { initialRegion ?? defaultRegion },
                set: { initialRegion = $0 }
            ),
            showsUserLocation: true,
            annotationItems: locationManager.gyms
        ) { gym in
            MapMarker(coordinate: gym.coordinate, tint: .blue)
        }
        .onReceive(locationManager.$initialRegion) { region in
            if let region = region {
                initialRegion = region
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .frame(width: 400, height: 700)
    }

    // Default region when initialRegion is nil
    private var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var gyms: [Gym] = []
    @Published var initialRegion: MKCoordinateRegion?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchNearbyGyms(for: location)
            initialRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }

    private func fetchNearbyGyms(for location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Gyms"
        request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for gyms: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let gyms = response.mapItems.map { Gym(name: $0.name ?? "Unknown Gym", coordinate: $0.placemark.coordinate) }
            DispatchQueue.main.async {
                self.gyms = gyms
            }
        }
    }
}
