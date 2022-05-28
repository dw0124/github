//
//  ViewController.swift
//  github
//
//  Created by 김두원 on 2022/05/08.
//
// Change something
import UIKit

class ViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var customTableView: UITableView!
    @IBOutlet weak var searchBar : UISearchBar!
    let cellIdetifier: String = "repositoryCell"
    var resultItems: [Items?] = []
    var fetchingMore: Bool = false
    var per_page:Int = 10
    var page:Int = 1
    var someData: Bool = false
    
    // MARK: - tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultItems.isEmpty ? 1 : resultItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = customTableView.dequeueReusableCell(withIdentifier: cellIdetifier) as? TableViewCell else { return UITableViewCell() }
        
        if resultItems.isEmpty {
            cell.fullnameLabel.text = "No Result!"
        } else {
            cell.fullnameLabel.text = resultItems[indexPath.row]?.full_name
            cell.descriptionLabel.text = resultItems[indexPath.row]?.description ?? ""
        }
        return cell
    }
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        customTableView.delegate = self
        customTableView.dataSource = self
        searchBar.delegate = self
        apiLoad()
    }
    
    // MARK: - API Load Data
    func apiLoad(qValue:String = "tetris", nextPage: Int = 1) {

        var components = URLComponents(string: "https://api.github.com/search/repositories")
        let q = URLQueryItem(name: "q", value: qValue)
        let order = URLQueryItem(name: "order", value: "desc")
        let perPage = URLQueryItem(name: "per_page", value: "\(per_page)")
        let pageCount = URLQueryItem(name: "page", value: "\(nextPage)")

        components?.queryItems = [q, order, perPage, pageCount]
        
        guard let url = components?.url else { print("URL failed"); return }
        
        // URLSession
        let session: URLSession = URLSession(configuration: .default)
        // dataTask
        let dataTask: URLSessionDataTask = session.dataTask(with: url) { data, response, error in
            
            if let e = error { print("Error: \(e.localizedDescription)") }
            
            guard let data = data else { print("Data is Nil!!"); return }
            
            // Json 데이터 디코드
            do{
                let apiResponse = try JSONDecoder().decode(Repositories.self, from: data)
                // someData를 통해 api를 불러온적이 있으면 append 함
                if !self.someData {
                    self.resultItems = apiResponse.items
                    self.someData = true
                } else {
                    self.resultItems.append(contentsOf: apiResponse.items)
                }
                print("success!!!!!")
                // 테이블뷰에 데이터 뿌려줌
                DispatchQueue.main.sync {
                    self.customTableView.reloadData()
                }
            } catch {
                print("catch Error: \(error)")
            }
        }
        return dataTask.resume()
    }

    // MARK - Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                let searchValue = searchBar.text!
                beginBatchFetch(searchValue: searchValue.isEmpty ? "tetris" : searchValue)
            }
        }
    }
    
    func beginBatchFetch(searchValue: String) {
        fetchingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: { [weak self] in
            guard let `self` = self else { return }
            self.page += 1
            self.apiLoad(qValue:searchValue, nextPage: self.page)
            print("---------------page : \(self.page)---------------")
            self.fetchingMore = false
            self.customTableView.reloadData()
        })
    }
    
}

// MARK: - SearBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { print("Text is Nil!!"); return }
        apiLoad(qValue: text)
    }
}

