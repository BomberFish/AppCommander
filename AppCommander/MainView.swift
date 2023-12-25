// bomberfish
// MainView.swift – AppCommander
// created on 2023-12-21

import SwiftUI

struct MainView: View {
    @State var apps: [Application] = []
    @State var allApps: [Application] = []
    
    @State var searchTerm: String = ""
    /// 0: none, 1: app name, 2: bundle id
    @AppStorage("procSortType") var sortType = 0
    /// 0: ascending, 1: descending
    @AppStorage("procSortDirection") var sortDirection = 0
    
    @ViewBuilder
    var nameMenu: some View {
        Menu(content: {
            Button(action: {
                Haptic.shared.selection()
                sortType = 1
                sortDirection = 0
                filterApps()
            }, label: {
                HStack {
                    Label("Ascending", systemImage: "arrow.up")
                    if sortType == 1 && sortDirection == 0 {
                        Image(systemName: "checkmark")
                    }
                }
            })
            Button(action: {
                Haptic.shared.selection()
                sortType = 1
                sortDirection = 1
                filterApps()
            }, label: {
                HStack {
                    Label("Descending", systemImage: "arrow.down")
                    if sortType == 1 && sortDirection == 1 {
                        Image(systemName: "checkmark")
                    }
                }
            })
        }, label: {
            Label("Name", systemImage: "textformat")
        })
    }
    
    @ViewBuilder
    var bundleIDMenu: some View {
        Menu(content: {
            Button(action: {
                Haptic.shared.selection()
                sortType = 2
                sortDirection = 0
                filterApps()
            }, label: {
                HStack {
                    Label("Ascending", systemImage: "arrow.up")
                    if sortType == 2 && sortDirection == 0 {
                        Image(systemName: "checkmark")
                    }
                }
            })
            Button(action: {
                Haptic.shared.selection()
                sortType = 2
                sortDirection = 1
                filterApps()
            }, label: {
                HStack {
                    Label("Descending", systemImage: "arrow.down")
                    if sortType == 2 && sortDirection == 1 {
                        Image(systemName: "checkmark")
                    }
                }
            })
        }, label: {
            Label("Bundle ID", systemImage: "terminal")
        })
    }
    
    var body: some View {
        NavigationView {
            if apps.isEmpty {
                VStack {
                    HStack {
                        ProgressView()
                        //.padding()
                        Text("Loading...")
                            .fontWeight(.semibold)
                    }
                    .padding()
                }
                .background(.regularMaterial)
                .cornerRadius(14)
            } else {
                List {
                    ForEach(apps, id: \.bundleIdentifier) {app in
                        NavigationLink(destination: AppView(app: app)) {
                            AppCell(app: app)
                        }
                    }
                }
                .listStyle(.inset)
                .navigationTitle("AppCommander")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Menu(content: {
                            Button(action: {
                                Haptic.shared.selection()
                                sortType = 0
                                sortDirection = 0
                                filterApps()
                            }, label: {
                                HStack {
                                    Label("None", systemImage: "minus")
                                    if sortType == 0 && sortDirection == 0 {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            })
                            
                            nameMenu
                            bundleIDMenu
                            
                        }, label: {
                            Image(systemName: sortType == 0 ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                        }) .onTapGesture {
                            Haptic.shared.selection()
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: searchTerm) {q in
            apps = allApps.filter({
                $0.name.localizedCaseInsensitiveContains(q) || $0.bundleIdentifier.localizedCaseInsensitiveContains(q)
            })
        }
        .onChange(of: sortType) {_ in
            filterApps()
        }
        .onChange(of: sortDirection) {_ in
            filterApps()
        }
        .refreshable {
            filterApps()
        }
        .onAppear {
            filterApps()
        }
    }
    
    func filterApps() {
        do {
            allApps = try AppManager.getApps()
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
        }
        apps = allApps
        switch sortType {
        case 1:
            if sortDirection == 1 {
                apps.sort {
                    $0.name > $1.name
                }
            } else {
                apps.sort {
                    $0.name < $1.name
                }
            }
        case 2:
            if sortDirection == 1 {
                apps.sort {
                    $0.name > $1.name
                }
            } else {
                apps.sort {
                    $0.name < $1.name
                }
            }
        default:
            print("not filtering")
        }
    }
}

#Preview {
    MainView()
}

struct AppCell: View {
    public var app: Application
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let icon = app.pngIconPaths[safe: 0] {
                if let uiimage: UIImage = .init(contentsOfFile: app.bundleURL.path + "/"  + icon) {
                    Image(uiImage: uiimage)
                        .resizable()
                        .frame(width: 42, height: 42)
                        .cornerRadius(10)
                } else {
                    Image("DefaultIcon")
                        .resizable()
                        .frame(width: 42, height: 42)
                        .cornerRadius(10)
                }
            } else {
                Image("DefaultIcon")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .cornerRadius(10)
            }
            VStack(alignment: .leading) {
                Text(app.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(app.bundleIdentifier)
                    Text("·")
                    Text(app.version)
                }
                    .lineLimit(1)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }
}
