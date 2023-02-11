//
//  ViewController.swift
//  Test
//
//  Created by MacS on 2023/02/11.
//

import UIKit
import SDWebImage
import MBProgressHUD

class ViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    var searchBar: UISearchBar!
    
    var searchResults = [SearchResult]()
    var currentPage = 1
    let pageLimit = 10
    
    var currentQuery: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLayout()
        
    }
    
    private func setUpLayout() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Enter text here"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (view.frame.width - 10) / 2, height: 300)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(UINib(nibName: SearchResultCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchResultCollectionViewCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func fetchData(query: String) {
        self.showProgress()
        let apiKey = "b9bd48a6"
        let type = "movie"
        
        let urlString = "http://www.omdbapi.com/?apikey=\(apiKey)&s=\(query)&type=\(type)&page=\(currentPage)"
        guard let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        if let url = URL(string: encodedUrlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    self.showAlert(message: error.localizedDescription)
                    self.dismisProgress()
                } else if let data = data {
                    do {
                        self.dismisProgress()
                        if let results = try? JSONDecoder().decode(SearchResults.self, from: data) {
                            if let newResults = results.search {
                                self.searchResults.append(contentsOf: newResults)
                                self.currentPage += 1
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            }
                        } else {
                            self.dismisProgress()
                            self.showAlert(message: "No Data")
                        }
                    } catch {
                        self.dismisProgress()
                        self.showAlert(message: error.localizedDescription)
                    }
                }
            }
            task.resume()
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCollectionViewCell.identifier, for: indexPath) as? SearchResultCollectionViewCell else {
            return UICollectionViewCell()
        }
        let searchResult = searchResults[indexPath.row]
        if let urlString = searchResult.poster {
            cell.image.sd_setImage(with: URL(string: urlString))
        }
        if let title = searchResult.title {
            cell.label.text = title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == searchResults.count - 1 {
            if let query = self.currentQuery {
                fetchData(query: query)
            }
        }
    }
}


extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        //if already has search query
        if let query = currentQuery, searchText.trimmingCharacters(in: .whitespacesAndNewlines) == query {
            return
        }
        currentQuery = searchText
        currentPage = 1
        searchResults.removeAll(keepingCapacity: false)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        fetchData(query: searchText)
        searchBar.resignFirstResponder()
    }
    
}

extension ViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showProgress() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    
    func dismisProgress() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}


